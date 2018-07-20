from keras.models import Sequential
from keras.layers import Conv2D, Conv2DTranspose, Input, BatchNormalization, PReLU
from keras.callbacks import ModelCheckpoint, Callback, TensorBoard
from keras.optimizers import SGD, Adam
import numpy as np
import math
import os
import random
from os import listdir, makedirs
from os.path import isfile, join, exists
from PIL import Image

import os.path, sys
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))
from s3sync import S3SyncCallback

def model(scale = 2):
    ch = 1
    d = 56
    s = 12
    m = 4
    c = 3
    SRCNN = Sequential()
    SRCNN.add(Conv2D(nb_filter=d, nb_row=5, nb_col=5, init='glorot_uniform', border_mode='same', bias=True, input_shape=(100, 100, ch)))
    SRCNN.add(PReLU(shared_axes=[1, 2]))
    SRCNN.add(Conv2D(nb_filter=s, nb_row=1, nb_col=1, init='glorot_uniform', border_mode='same', bias=True))
    SRCNN.add(PReLU(shared_axes=[1, 2]))
    for i in range(m):
        SRCNN.add(Conv2D(nb_filter=s, nb_row=3, nb_col=3, init='glorot_uniform', border_mode='same', bias=True))
        SRCNN.add(PReLU(shared_axes=[1, 2]))
    SRCNN.add(Conv2D(nb_filter=d, nb_row=1, nb_col=1, init='glorot_uniform', border_mode='same', bias=True))
    SRCNN.add(PReLU(shared_axes=[1, 2]))
    SRCNN.add(Conv2DTranspose(filters=ch, kernel_size=(9,9), strides=(scale, scale), init='glorot_uniform', border_mode='same', bias=True))

    adam = Adam(lr=0.0003)
    SRCNN.compile(optimizer=adam, loss='mean_squared_error', metrics=['mean_squared_error'])
    return SRCNN

class MyDataGenerator(object):

    def flow_from_directory(self, input_dir, label_dir, batch_size=32):
        images = []
        labels = []
        while True:
            files = listdir(input_dir)
            random.shuffle(files)
            for f in files:
                images.append(self.load_image(input_dir, f))
                labels.append(self.load_image(label_dir, f))
                if len(images) == batch_size:
                    x_inputs = np.asarray(images)
                    x_labels = np.asarray(labels)
                    images = []
                    labels = []
                    yield x_inputs, x_labels

    def load_image(self, src_dir, f):
        img = Image.open(join(src_dir, f))
        X = np.asarray(img.convert('YCbCr'), dtype='float32')
        X = X[:,:,0]
        X /= 255.
        X = np.reshape(X,(X.shape[0], X.shape[1], 1))
        return X

def train(log_dir, model_dir, train_dir, test_dir, eval_img, scale, epochs, steps, sync_s3):
    srcnn_model = model(scale)
    print(srcnn_model.summary())

    datagen = MyDataGenerator()
    train_gen = datagen.flow_from_directory(os.path.join(
        train_dir, 'input'),
        os.path.join(train_dir, 'label'),
        batch_size = 10)

    val_gen = datagen.flow_from_directory(
        os.path.join(test_dir, 'input'),
        os.path.join(test_dir, 'label'),
        batch_size = 10)

    class PSNRCallback(Callback):
        def on_epoch_end(self, epoch, logs=None):
            loss = logs['loss'] * 255.
            val_loss = logs['val_loss'] * 255.
            psnr = 20 * math.log10(255. / math.sqrt(loss))
            val_psnr = 20 * math.log10(255. / math.sqrt(val_loss))
            print("\n")
            print("PSNR:%s" % psnr)
            print("PSNR(val):%s" % val_psnr)

    ps_cb = PSNRCallback()
    md_cb = ModelCheckpoint(os.path.join(model_dir,'check.h5'), monitor='val_loss', verbose=1, save_best_only=True, save_weights_only=False, mode='min', period=1)
    tb_cb = TensorBoard(log_dir=log_dir)
    s3_cb = S3SyncCallback(s3_base_url='s3://tryswift/super-resolution-kit/log', log_dir=log_dir, sync = sync_s3)

    srcnn_model.fit_generator(
        generator = train_gen,
        steps_per_epoch = steps,
        validation_data = val_gen,
        validation_steps = steps,
        epochs = epochs,
        callbacks=[ps_cb, md_cb, tb_cb, s3_cb])

    srcnn_model.save(os.path.join(model_dir,'model.h5'))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("log_dir")
    parser.add_argument("model_dir")
    parser.add_argument("train_dir")
    parser.add_argument("test_dir")
    parser.add_argument("--eval_img")
    parser.add_argument("-scale", type=int, default=2)
    parser.add_argument("-epochs", type=int, default=100)
    parser.add_argument("-steps", type=int, default=100)
    parser.add_argument("-sync", type=bool, default=False)
    args = parser.parse_args()
    print(args)

    if not exists(args.model_dir):
        makedirs(args.model_dir)

    train(args.log_dir, args.model_dir, args.train_dir, args.test_dir, args.eval_img, args.scale, args.epochs, args.steps, args.sync)
