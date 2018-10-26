import skimage.io as skio
import skimage.color as skc
import skimage.feature as skfeat
import skimage.filters as skfill
import skimage.morphology as skmorph
import skimage.measure as skmeasure
import numpy as np
import cv2 as cv


def cropped_photo_to_print(img_location, blocksize=151, k_median=21, med_disk_size=4):
    img = skio.imread(img_location)
    img_copy = img.copy()
    imgray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
    eqlzd = cv.equalizeHist(imgray)
    th3 = cv.adaptiveThreshold(eqlzd, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, blocksize, 5)
    th3_median = cv.medianBlur(th3, ksize=k_median)

    _, contours, _ = cv.findContours(th3_median, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

    areas = [cv.contourArea(c) for c in contours]
    top_5 = sorted(areas[:])[-5:]
    area_indicies = [areas.index(c) for c in top_5]
    biggest_contours = [contours[i] for i in area_indicies]

    mask = np.zeros_like(img_copy)
    cv.drawContours(mask, biggest_contours, -1, 255, -1);
    mask = cv.cvtColor(mask, cv.COLOR_BGR2GRAY)
    markers = skmeasure.label(mask)

    mask = markers == markers[markers.shape[0] // 2][markers.shape[1] // 2]  # finding the center marker

    # crop
    # https://stackoverflow.com/questions/28759253/how-to-crop-the-internal-area-of-a-contour
    (x, y) = np.where(mask)
    (topx, topy) = (np.min(x), np.min(y))
    (bottomx, bottomy) = (np.max(x), np.max(y))
    coords = [topx - 20, bottomx + 21, topy - 20, bottomy + 21]
    imgray = skc.rgb2gray(img)
    imgray = imgray[coords[0]:coords[1], coords[2]:coords[3]]

    imgray_c = imgray.copy()
    local_thresh = skfill.threshold_local(imgray_c, 31)
    binary_local = imgray_c > local_thresh

    mask = mask[coords[0]:coords[1], coords[2]:coords[3]]
    binary_local[mask != 1] = 0
    binary_local = ~binary_local

    median_with_mask = skfill.median(binary_local, selem=skmorph.disk(med_disk_size))

    return median_with_mask
