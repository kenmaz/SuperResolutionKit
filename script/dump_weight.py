from keras.models import Sequential, Model
from keras.layers import Conv2D, Input, BatchNormalization
from keras.callbacks import ModelCheckpoint
from keras.optimizers import SGD, Adam
import numpy as np
import math
import os
from keras.models import load_model
from PIL import Image

def setup_session():
    import tensorflow as tf
    from keras.backend import tensorflow_backend
    config = tf.ConfigProto(gpu_options=tf.GPUOptions(allow_growth=True))
    session = tf.Session(config=config)
    tensorflow_backend.set_session(session)

def save_as_img(prefix, out_dir, patch):
    patch = np.reshape(patch, (patch.shape[0],patch.shape[1]))
    img = Image.fromarray(patch)
    path = '%s/%s_patch.png' % (out_dir,prefix)
    img.save(path)

def dump_weight(model, out_dir):
    weights = model.get_weights()
    print len(weights),'weights'
    for w in weights:
        print(w.shape)

    print('1st layer masks')
    w = weights[0]
    ch = w.shape[3]
    patch_size = w.shape[0]

    grid_layout = [int(math.ceil(ch/10.)), 10]
    grid_size = [grid_layout[0] * patch_size, grid_layout[1] * patch_size]
    space = 5
    grid_size = [grid_size[0] + space * grid_layout[0], grid_size[1] + space * grid_layout[1]]
    dist_img = Image.new('L', grid_size)
    print grid_layout

    baseline = abs(min(w.flatten().tolist()))
    w = w + baseline
    topval = max(w.flatten().tolist())
    w = w / topval * 255
    w = np.uint8(w)

    for c in range(0, ch):
        mask = w[:,:,0,c]
        #save_as_img('weight-%d'%c, out_dir, mask)
        img = Image.fromarray(mask)
        x = int(c/grid_layout[1])
        y = int(c%grid_layout[1])
        pos = (x*patch_size + x*space, y*patch_size + y*space)
        print(pos)
        dist_img.paste(img, pos)

    path = '%s/weights.png' % out_dir
    print path
    dist_img.save(path)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("model", help="model file path")
    parser.add_argument("out_dir", help="output dir")
    args = parser.parse_args()
    #print(args)

    if not os.path.exists(args.out_dir):
        os.makedirs(args.out_dir)

    model = load_model(args.model)
    dump_weight(model, args.out_dir)

