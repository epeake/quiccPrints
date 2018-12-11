import skimage.filters as skfill
import skimage.morphology as skmorph
import skimage.measure as skmeasure
import skimage.exposure as ske
import numpy as np
import cv2 as cv
import heapq
import sys


def sin2d(u, v, ii, jj, N, M):
    """
    Makes our high frequency sine waves
    """
    selem = np.sin(u * ii / (2 * np.pi) + v * jj / (2 * np.pi))
    return selem * 255 / (N * M)


def high_freq_detection(imgray):
    """
    Creates new image to detect regions
    """
    N = 200
    M = 200
    i = np.linspace(0, N - 1, N)
    j = np.linspace(0, M - 1, M)
    jj, ii = np.meshgrid(j, i)

    # gabor doesn't work because of the gray on the outside, but maybe make it black
    fill_1 = sin2d(2, 2, ii, jj, N, M)
    fill_2 = sin2d(1, 2, ii, jj, N, M)
    fill_3 = sin2d(2, 1, ii, jj, N, M)
    fill_4 = sin2d(-2, 1, ii, jj, N, M)
    fill_5 = sin2d(-2, 2, ii, jj, N, M)
    fill_6 = sin2d(-2, 3, ii, jj, N, M)

    new_img = np.zeros(imgray.shape)
    conv_1 = cv.filter2D(imgray, -1, fill_1)
    conv_2 = cv.filter2D(imgray, -1, fill_2)
    conv_3 = cv.filter2D(imgray, -1, fill_3)
    conv_4 = cv.filter2D(imgray, -1, fill_4)
    conv_5 = cv.filter2D(imgray, -1, fill_5)
    conv_6 = cv.filter2D(imgray, -1, fill_6)
    new_img += conv_1 + conv_2 + conv_3 + conv_4 + conv_5 + conv_6

    return new_img


def thresh_series_mask(median_img, imgray):
    """
    Find all regions
    """
    block_sizes = [21, 41, 51, 61, 81]
    masks = []
    for block_size in block_sizes:
        local_thresh = skfill.threshold_local(median_img, block_size)
        binary_local = median_img > local_thresh
        labels = skmeasure.label(binary_local)

        hight_freq_img = high_freq_detection(imgray)

        label_props = skmeasure.regionprops(labels)
        areas = [label_props[i]["area"] for i in range(len(label_props))]
        max_areas = heapq.nlargest(15, areas)
        max_indicies = [areas.index(max_areas[i]) + 1 for i in range(len(max_areas))]

        max_i = 0
        max_count = 0
        for i in range(len(max_indicies)):
            label_vals = labels == max_indicies[i]
            current_count = (label_vals.astype(int) * hight_freq_img).sum()
            if current_count > max_count:
                max_count = current_count
                max_i = max_indicies[i]

        mask = labels == max_i
        masks.append(mask)

    mask = np.zeros(masks[0].shape).astype(bool)

    for m in masks:
        mask = mask | m

    mask = skmorph.binary_closing(mask, selem=skmorph.disk(30))
    return skmorph.binary_erosion(mask, selem=skmorph.disk(10))


def extract_print(mask, imgray):
    """
    Get print, given the mask
    """
    imgray[mask != 1] = 0
    block_size = 41
    local_thresh = skfill.threshold_local(imgray, block_size)
    binary_local = imgray > local_thresh
    binary_local[mask == 0] = 1
    f_print = skfill.median(binary_local, selem=skmorph.disk(3))

    return f_print


if __name__ == "__main__":
    # os.chdir("/Users/epeake/Sync/Midd/jr/S1/Image Processing/Project")
    imgray = cv.imread(sys.argv[1], cv.IMREAD_GRAYSCALE)[1500:3000, 1000:2000]
    imgray_eq = ske.equalize_hist(imgray)
    med = skfill.median(imgray_eq, selem=skmorph.disk(21))
    f_print = extract_print(thresh_series_mask(med, imgray), imgray)
