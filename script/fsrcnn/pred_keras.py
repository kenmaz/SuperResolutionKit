from keras.models import Sequential
from keras.layers import Conv2D, Input, BatchNormalization
from keras.callbacks import ModelCheckpoint
from keras.optimizers import SGD, Adam
import numpy as np
import math
import os
from keras.models import load_model
from PIL import Image

patch_size = 100

def setup_session():
    import tensorflow as tf
    from keras.backend import tensorflow_backend
    config = tf.ConfigProto(gpu_options=tf.GPUOptions(allow_growth=True))
    session = tf.Session(config=config)
    tensorflow_backend.set_session(session)

def predict2(model, input_file, out_dir, scale = 2.0, ch = 1):
    basename = os.path.basename(input_file)
    filename, ext = os.path.splitext(basename)

    img = Image.open(input_file)
    img.save('%s/%s_org%s' % (out_dir, filename, ext))
    img = img.convert('YCbCr')

    yuv = np.asarray(img)
    y_img = yuv[:,:,0]
    y_img_shape = y_img.shape
    y_img = Image.fromarray(y_img)
    y_img.save('%s/%s_org_y%s' % (out_dir, filename, ext))

    lr_size = tuple([int(x/scale) for x in img.size])
    lr_img = img.resize(lr_size, Image.BICUBIC)
    lr_img.resize(img.size, Image.BICUBIC).convert('RGB').save('%s/%s_lr%s' % (out_dir, filename, ext))

    ylr_img = np.asarray(lr_img)[:,:,0]
    ylr_img = np.uint8(ylr_img)
    Image.fromarray(ylr_img).resize(img.size, Image.BICUBIC).save('%s/%s_ylr%s' % (out_dir, filename, ext))
    ylr_img = np.reshape(ylr_img, (ylr_img.shape[0],ylr_img.shape[1],ch))

    y_hr = predict_hr_img(model, ylr_img, y_img_shape, scale, out_dir)
    y_hr = np.uint8(y_hr)
    h,w,c = yuv.shape
    y_hr = y_hr[0:h,0:w]
    #Image.fromarray(hr_ary).save('%s/%s_hr%s' % (out_dir, filename, ext))

    merge_save('%s/%s_hr_merge%s' % (out_dir, filename, ext), yuv, y_hr)

def predict_hr_img(model, lr_img, hr_img_size, scale, out_dir):
    hr_img = np.zeros((hr_img_size[1], hr_img_size[0], 1)) # h<->w exchanged
    print(hr_img.shape)
    print(lr_img.shape)

    h,w,ch = lr_img.shape
    eh = h if h % patch_size == 0 else h + patch_size - (h % patch_size) # 240 % 100=40, 240+100-
    ew = w if w % patch_size == 0 else w + patch_size - (w % patch_size)
    print('extend:',eh,ew,ch)
    lr_base = np.zeros((eh, ew, ch), dtype='uint8')
    lr_base[0:h, 0:w] = lr_img
    lr_img = lr_base
    hr_img = np.zeros((int(eh * scale), int(ew * scale), ch)) # h<->w exchanged

    for y in range(0, h, patch_size):
        for x in range(0, w, patch_size):
            patch = lr_img[y:y+patch_size, x:x+patch_size]
            #save_as_img('lr',out_dir, patch, y, x)
            patch = patch/255.
            patch = patch.reshape(1, patch.shape[0],patch.shape[1],patch.shape[2])
            res = model.predict(patch, batch_size=1)
            res = res*255.
            res = np.clip(res, 0, 255) #important
            res = np.uint8(res)
            res = res.reshape(res.shape[1],res.shape[2],res.shape[3])
            #save_as_img('hr',out_dir, res, y, x)
            dy = int(y * scale)
            dh = dy + int(patch_size * scale)
            dx = int(x * scale)
            dw = dx + int(patch_size * scale)
            hr_img[dy:dh,dx:dw] = res

    return hr_img

def merge_save(dst_path, yuv, y):
    y = np.reshape(y, (y.shape[0], y.shape[1]))
    dst = yuv.copy()
    dst[:,:,0] = y
    img = Image.fromarray(dst, mode='YCbCr')
    img = img.convert('RGB')
    img.save(dst_path)

def save_as_img(prefix, out_dir, patch, y, x):
    patch = np.reshape(patch, (patch.shape[0],patch.shape[1]))
    img = Image.fromarray(patch)
    path = '%s/%s_patch_%d_%d.png' % (out_dir,prefix,y,x)
    img.save(path)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("model", help="model file path")
    parser.add_argument("input", help="row res image path")
    parser.add_argument("out_dir", help="output dir")
    parser.add_argument("-scale", type=int, default=2)
    args = parser.parse_args()
    print(args)

    if not os.path.exists(args.out_dir):
        os.makedirs(args.out_dir)

    setup_session()
    model = load_model(args.model)

    predict2(model, args.input, args.out_dir, args.scale)
    print('fin')
