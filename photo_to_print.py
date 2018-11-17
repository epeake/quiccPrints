import skimage.io as skio
import skimage.color as skc
import skimage.filters as skfill
import skimage.morphology as skmorph
import skimage.measure as skmeasure
import skimage.exposure as ske
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
import heapq



imgray = cv.imread("Jack2.jpeg", cv.IMREAD_GRAYSCALE)[1000:3000, 1000:2300]
fig = plt.figure()
plt.imshow(imgray, cmap='gray')
imgray_eq = ske.equalize_hist(imgray)
fig = plt.figure()
plt.imshow(imgray_eq, cmap='gray')
med = skfill.median(imgray_eq, selem=skmorph.disk(21))
fig = plt.figure()
plt.imshow(med, cmap='gray')

block_size = 51
local_thresh = skfill.threshold_local(med, block_size)
binary_local = med > local_thresh
fig = plt.figure()
plt.imshow(binary_local, cmap='gray')
labels = skmeasure.label(binary_local)
fig = plt.figure()
plt.imshow(skc.label2rgb(labels), cmap='gray')


N = 200
M = 200
i = np.linspace(0, N-1, N)
j = np.linspace(0, M-1, M)
jj, ii = np.meshgrid(j, i)


def sin2d(u, v, ii, jj, N, M):
    selem = np.sin(u * ii/(2*np.pi) + v * jj/(2*np.pi))
    return selem * 255 / (N * M)


# gabor doesn't work because of the gray on the outside, but maybe make it black
fill_1 = sin2d(2, 2, ii, jj, N, M)
fill_2 = sin2d(1, 2, ii, jj, N, M)
fill_3 = sin2d(2, 1, ii, jj, N, M)
fill_4 = sin2d(-2, 1, ii, jj, N, M)
fill_5 = sin2d(-2, 2, ii, jj, N, M)
fill_6 = sin2d(-2, 3, ii, jj, N, M)

fig = plt.figure()
plt.imshow(fill_1, cmap='gray')

new_img = np.zeros(imgray.shape)
conv_1 = cv.filter2D(imgray, -1, fill_1)
conv_2 = cv.filter2D(imgray, -1, fill_2)
conv_3 = cv.filter2D(imgray, -1, fill_3)
conv_4 = cv.filter2D(imgray, -1, fill_4)
conv_5 = cv.filter2D(imgray, -1, fill_5)
conv_6 = cv.filter2D(imgray, -1, fill_6)
new_img += conv_1 + conv_2 + conv_3 + conv_4 + conv_5 + conv_6
fig = plt.figure()
plt.imshow(new_img, cmap="gray")

label_props = skmeasure.regionprops(labels)
areas = [label_props[i]["area"] for i in range(len(label_props))]
max_areas = heapq.nlargest(15, areas)
max_indicies = [areas.index(max_areas[i]) + 1 for i in range(len(max_areas))]

max_i = 0
max_count = 0
for i in range(len(max_indicies)):
    label_vals = labels == max_indicies[i]
    current_count = (label_vals.astype(int) * new_img).sum()
    if current_count > max_count:
        max_count = current_count
        max_i = max_indicies[i]

mask = labels == 644
fig = plt.figure()
plt.imshow(mask, cmap="gray")

mask = skmorph.binary_closing(mask, selem=skmorph.disk(40))
fig = plt.figure()
plt.imshow(mask, cmap="gray")

imgray[mask != 1] = 0
fig = plt.figure()
plt.imshow(imgray, cmap="gray")

block_size = 41
local_thresh = skfill.threshold_local(imgray, block_size)
binary_local = imgray > local_thresh
fig = plt.figure()
plt.imshow(binary_local, cmap='gray')

binary_local[mask == 0] = 1
fig = plt.figure()
plt.imshow(binary_local, cmap='gray')

print = skfill.median(binary_local, selem=skmorph.disk(3))
fig = plt.figure()
plt.imshow(print, cmap='gray')

skio.imsave("./print_new.jpg", print)
