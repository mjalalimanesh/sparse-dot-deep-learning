"""
Created on Wed Jun 19 13:25:04 2019
@author: Mohamad Jalali Manesh

Metrics for evaluating model accuracy
"""

from skimage.metrics import structural_similarity as sk_ssim
import numpy as np


def MAE(y_test, y_pred):
    """  Mean absolute error """
    abe = np.sum(np.abs(y_test - y_pred)) / (y_test.shape[0] * y_test.shape[1])
    return abe


def VAR(y_test, y_pred):
    """ Variation Error """
    var = np.sum(y_test - np.mean(y_pred)) / (y_test.shape[0] * y_test.shape[1])
    return var


def MSE(y_test, y_pred):
    """ Mean Squared Error """
    mse = np.sum((y_test - y_pred) ** 2) / (y_test.shape[0] * y_test.shape[1])
    return mse


def PSNR(y_test, y_pred):
    """ Peak Signal to Noise Ratio """
    mse = MSE(y_test, y_pred)
    ps = np.max(y_pred)
    psnr = 10 * np.log10(ps ** 2 / mse)
    return psnr


def CNR1(y_test, y_pred):
    """ Contrast to Noise Ratio 1 """
    mask_bg = y_test == 0.001
    mask_roi = y_test > 0.001

    mean_roi = np.mean(y_pred[mask_roi])
    std_roi = np.std(y_pred[mask_roi])

    mean_bg = np.mean(y_pred[mask_bg])
    std_bg = np.std(y_pred[mask_bg])

    cnr = (mean_roi - mean_bg) / std_bg

    return cnr


def CNR2(y_test, y_pred):
    """ Contrast to Noise Ratio 2 """
    mask_bg = y_test == 0.001
    mask_roi = y_test > 0.001

    mean_roi = np.mean(y_pred[mask_roi])
    std_roi = np.std(y_pred[mask_roi])

    mean_bg = np.mean(y_pred[mask_bg])
    std_bg = np.std(y_pred[mask_bg])

    cnr = (mean_roi - mean_bg) / np.sqrt(std_bg ** 2 + std_roi ** 2)

    return cnr


def SSIM(y_test_i, y_pred_i):
    """ Structutal Similarity Index """
    s, m = sk_ssim(
        y_test_i, y_pred_i, data_range=(y_test_i.max() - y_test_i.min()), full=True
    )
    return s, m


def pascal_localization_metric(y_test, y_pred, scale_test, scale_pred):
    """ Pascal Localization accuracy metric """
    gt = np.zeros_like(y_test)
    loc = np.zeros_like(y_pred)
    gt[y_test > scale_test * y_test.max()] = 1
    gt[y_test <= scale_test * y_test.max()] = 0
    loc[y_pred > scale_pred * y_pred.max()] = 1
    loc[y_pred <= scale_pred * y_pred.max()] = 0
    count_intersection = np.sum(np.logical_and(gt, loc))
    count_union = np.sum(loc) + np.sum(gt) - count_intersection
    return count_intersection / count_union
