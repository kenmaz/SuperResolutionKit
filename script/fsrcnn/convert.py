from os import listdir, makedirs
from os.path import isfile, join, exists

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input_dir", help="Data input directory")
parser.add_argument("output_dir", help="Data output directory")
parser.add_argument("-scale", type=int, default=2, help="Scale")
args = parser.parse_args()
print(args)

import numpy as np
from scipy import misc
from PIL import Image
from tqdm import tqdm

scale = float(args.scale)
patch_size = 100
label_size = int(patch_size * scale)
stride = patch_size

if not exists(args.output_dir):
    makedirs(args.output_dir)
if not exists(join(args.output_dir, "input")):
    makedirs(join(args.output_dir, "input"))
if not exists(join(args.output_dir, "label")):
    makedirs(join(args.output_dir, "label"))

count = 1
dirs = listdir(args.input_dir)

for i in tqdm(range(len(dirs))):
    f = dirs[i]
    f = join(args.input_dir, f)
    if not isfile(f):
        continue

    image = np.asarray(Image.open(f).convert('RGB'))
    #print(f, image.shape)

    h, w, c = image.shape

    scaled = misc.imresize(image, 1.0/scale, 'bicubic')

    for y in range(0, h - label_size + 1, stride):
        for x in range(0, w - label_size + 1, stride):
            (x_p, y_p) = (int(x/scale), int(y/scale))
            #print(y,x,y_p,x_p)
            sub_img_patch = scaled[y_p : y_p + patch_size, x_p : x_p + patch_size]
            sub_img_label = image[y : y + label_size, x : x + label_size]
            misc.imsave(join(args.output_dir, "input", str(count) + '.png'), sub_img_patch)
            misc.imsave(join(args.output_dir, "label", str(count) + '.png'), sub_img_label)

            count += 1
