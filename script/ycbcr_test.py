from PIL import Image
import numpy as np
import sys
img = Image.open(sys.argv[1]).convert('YCbCr')
#print img
data = np.asarray(img)
#print data
print data.shape
Image.fromarray(data[:,:,0]).save('ch_Y.png')
Image.fromarray(data[:,:,1]).save('ch_Cb.png')
Image.fromarray(data[:,:,2]).save('ch_Cr.png')
print np.max(data[:,:,0])
print np.min(data[:,:,0])
print(data[:,:,0])
