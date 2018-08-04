from keras.models import Sequential, Model
from keras.layers import Conv2D, Input, BatchNormalization
from keras.callbacks import ModelCheckpoint
from keras.optimizers import SGD, Adam
import numpy as np
import math
import os
from keras.models import load_model
from PIL import Image

patch_size = 200

def setup_session():
    import tensorflow as tf
    from keras.backend import tensorflow_backend
    config = tf.ConfigProto(gpu_options=tf.GPUOptions(allow_growth=True))
    session = tf.Session(config=config)
    tensorflow_backend.set_session(session)

def predict(model, input_lr_patch_file, out_dir, scale = 2.0, ch = 1):
    basename = os.path.basename(input_lr_patch_file)
    filename, ext = os.path.splitext(basename)

    img = Image.open(input_lr_patch_file)
    img = img.convert('YCbCr')

    y_ary = np.asarray(img)[:,:,0]
    y_ary = np.uint8(y_ary)/255.
    y_ary = np.reshape(y_ary, (1, y_ary.shape[0],y_ary.shape[1], ch))
    dump_intermediate_layer('conv2d_1', model, y_ary, out_dir)
    dump_intermediate_layer('conv2d_2', model, y_ary, out_dir)
    dump_intermediate_layer('conv2d_3', model, y_ary, out_dir)
    """
            res = res*255.
            res = np.clip(res, 0, 255) #important
            res = np.uint8(res)
            res = res.reshape(res.shape[1],res.shape[2],res.shape[3])
    """

def dump_intermediate_layer(layer_name, model, patch, out_dir):
    dump_model = Model(
            inputs=model.input,
            outputs=model.get_layer(layer_name).output)
    dump = dump_model.predict(patch, batch_size=1)
    num_ch = dump.shape[3]

    grid_layout = [int(math.ceil(num_ch/10.)), 10]
    grid_size = [grid_layout[0] * patch_size, grid_layout[1] * patch_size]
    dist_img = Image.new('L', grid_size)
    print grid_layout

    for ch in range(0, num_ch):
        res = dump[0,:,:,ch]

        w1 = res
        baseline = abs(min(w1.flatten().tolist()))
        w1 = w1 + baseline
        topval = max(w1.flatten().tolist())
        w1 = w1 / topval * 255
        w1 = np.uint8(w1)
        res = w1

        #res = res*255.
        #res = np.clip(res, 0, 255) #important
        #res = np.uint8(res)
        img = Image.fromarray(res)
        pos = (int(ch/grid_layout[1])*patch_size, int(ch%grid_layout[1])*patch_size)
        dist_img.paste(img, pos)

    path = '%s/%s_grid.png' % (out_dir, layer_name)
    print path
    dist_img.save(path)

def save_as_img(prefix, out_dir, patch):
    patch = np.reshape(patch, (patch.shape[0],patch.shape[1]))
    img = Image.fromarray(patch)
    path = '%s/%s_patch.png' % (out_dir,prefix)
    img.save(path)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("model", help="model file path")
    parser.add_argument("input", help="row res patch image path")
    parser.add_argument("out_dir", help="output dir")
    parser.add_argument("-scale", type=int, default=2)
    args = parser.parse_args()
    #print(args)

    if not os.path.exists(args.out_dir):
        os.makedirs(args.out_dir)

    setup_session()
    model = load_model(args.model)

    predict(model, args.input, args.out_dir, args.scale)
    #print('fin')
