import skimage.feature as skfeat
import skimage.filters as skfill
import skimage.morphology as skmorph
import skimage.measure as skmeasure


def cropped_photo_to_print(img, block_size, disk_size):
    img[img < .55] = 0
    local_thresh = skfill.threshold_local(img, block_size)
    binary_local = img > local_thresh
    binary_local_no_mask = binary_local.copy()
    edges = skfeat.canny(img, sigma=.2)
    dialated_edges = skmorph.binary_dilation(edges, selem=skmorph.disk(5))
    markers = skmeasure.label(~dialated_edges)
    mask = markers == 1
    mask_dilate = skmorph.dilation(mask, selem=skmorph.disk(10))
    binary_local[mask_dilate == 1] = 1
    median_with_mask = skfill.median(binary_local, selem=skmorph.disk(disk_size))

    return binary_local_no_mask, binary_local, median_with_mask