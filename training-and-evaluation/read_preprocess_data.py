# -*- coding: utf-8 -*-
"""
Functions to read and preprocess data
read_preprocess_data is the main function

Created on Mon Jun 17 2019
@author: Mohamad Jalalimanesh
"""

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from matplotlib import pyplot as plt
import h5py


def read_from_memory(include_double=False):
    """
    read data from memory
    data is initially in matlab .mat format
    Input:
            include_double : bool, to include double inclusion phantoms or not
    Output:
            (net_input, net_output) : 2 n*d arrays containing data, input
                                                                    and output of NN
    """
    single_inclusion_num = 30000
    double_inclusion_num = 14000
    f = h5py.File("network_outputs.mat", "r")
    tmp = f["bbmua_save"].value
    net_output_single = np.array(tmp).T.reshape(
        (single_inclusion_num, 4096)
    )  # converting to a NumPy array
    tmp = f["Y_save"].value
    net_input_single = np.array(tmp).T  # converting to a NumPy array
    if include_double:
        f1 = h5py.File("network_outputs_double.mat", "r")
        tmp = f1["bbmua_save"].value
        net_output_double = np.array(tmp).T.reshape(
            (double_inclusion_num, 4096)
        )  # For converting to a NumPy array
        tmp = f1["Y_save"].value
        net_input_double = np.array(tmp).T  # For converting to a NumPy array
        # concatenate single inclusion and double inclusion data
        net_output = np.concatenate((net_output_single, net_output_double), axis=0)
        net_input = np.concatenate((net_input_single, net_input_double), axis=0)

        return net_input, net_output

    return net_input_single, net_output_single


def read_preprocess_data(
    subtract_homogen=True, is_standard_scalar_input=True, noise_level=0.0
):
    """
    Read training and test data from memory, preprocess and split
    them
    Args:
            include_homogen : [bool] to subtract homogenoues data from boundary
            measurements or not
            is_standard_scalar_input : [bool] make input standard
            noise_level : level of noise

    Output:
            x_train : network input data used for trainig
            y_train, x_val, y_val, x_test, y_test, stand
    """
    net_input, net_output = read_from_memory()
    net_input = my_normalizer(net_input)

    total_num = net_input.shape[0]
    test_num = 1000
    val_num = 2000

    net_input = scale(net_input)
    net_input = one_fit(net_input)
    net_input = np.log(net_input)

    net_input = add_noise(net_input, noise_level)

    if subtract_homogen:
        net_input = subtract_homogen_data(net_input)

    if is_standard_scalar_input:
        stand = preprocessing.StandardScaler().fit(net_input)
        net_input = stand.transform(net_input)

    indices = np.arange(total_num)  # to help find index of test data for later use

    # split data to train, validation and test. X : network input, Y : network output
    X_train, x_test, Y_train, y_test, _, id_test = train_test_split(
        net_input, net_output, indices, test_size=test_num, random_state=4
    )

    x_train, x_val, y_train, y_val = train_test_split(
        X_train, Y_train, test_size=val_num, random_state=3
    )

    return x_train, y_train, x_val, y_val, x_test, y_test, stand


def subtract_homogen_data(net_input):
    """
    Subtract homogenoues boundary measurements from all boundary measurements
    """
    Homo_input = pd.read_csv("homo.txt", sep=",", header=None).values
    Homo_input = Homo_input.T[:, :] / np.max(Homo_input[:, :])
    Homo_input = scale(Homo_input)
    Homo_input = np.log(one_fit(Homo_input))
    net_input_ = Homo_input - net_input
    return net_input_


def scale(input_value, scale_value=0.9111):
    return input_value * scale_value


def remove_0_background(one_net_output):
    nonzero_ind = np.nonzero(one_net_output)[0]
    zero_ind = ~np.nonzero(one_net_output)[0]
    return nonzero_ind, zero_ind


def my_normalizer(net_input):
    """
    Normalizes Input by dividing by max value of input
    """
    net_input_ = net_input / np.max(net_input, axis=1).reshape(net_input.shape[0], 1)
    return net_input_


def min_fit(net_input):
    net_input_ = (
        net_input - np.min(net_input, axis=1).reshape(net_input.shape[0], 1)
    ) + 0.1
    return net_input_


def one_fit(net_input):
    """
    make max value of input equal to one by adding appropriate values to it
    """
    net_input_ = net_input + (
        1 - np.max(net_input, axis=1).reshape(net_input.shape[0], 1)
    )
    return net_input_


def remove_big_in_input(net_input):
    indeces = [i * 16 + i for i in range(16)]
    tmp = np.ones((256,), dtype=np.bool)
    tmp[indeces] = 0
    #    tmp = tmp.reshape((16,16))
    return net_input[:, tmp]


def change_order(net_output, chunksize=22090):
    grd = (64, 64)
    net_output_ = np.zeros((chunksize, grd[0] * grd[1]))
    for i in range(chunksize):
        a = net_output[i, :].reshape(grd, order="F")
        net_output_[i, :] = a.reshape((grd[0] * grd[1],))
    return net_output_


def add_noise(net_input, level=0.0):
    net_input_ = (
        net_input + np.random.normal(0.0, 1, net_input.shape) * level * net_input
    )
    return net_input_


def add_white_noise(net_input, level=0.0):
    net_input_ = net_input + np.random.normal(0.0, 1, net_input.shape) * level * 1
    return net_input_


def multiply_noise(net_input, level=0.0):
    net_input_ = net_input * (1 + np.random.normal(0.0, 1, net_input.shape) * level)
    return net_input_


from skimage.transform import resize


def resize_output(net_output, grd):
    """
    resize output image resolution from 64*64 to grd
    """
    net_output_ = np.zeros((net_output.shape[0], grd[0] * grd[1]))
    for i in range(net_output.shape[0]):
        a = net_output[i, :].reshape((64, 64))
        image_rescaled = resize(a, grd, anti_aliasing=False, order=3)  # order 1,3
        net_output_[i, :] = image_rescaled.reshape((grd[0] * grd[1],), order="F")
    return net_output_
