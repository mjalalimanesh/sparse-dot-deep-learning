# -*- coding: utf-8 -*-
"""
Created on Wed Jun 12 12:28:16 2019
get_nth_layer_output( X,  model, n, phase = 'test'):
    X : data
    model : model which we want nth layer output
    phase : to return output in train or test phase
@author: Mohamad Jalali Manesh
"""

from tensorflow.keras import backend as K
#import keras
#from keras.models import Sequential


def get_nth_layer_output( X,  model, n, phase = 'test'):
    get_output = K.function([model.layers[0].input , K.learning_phase() ], \
                             [model.layers[n].output] )
    
    if phase == 'test' :
        return get_output([X,0])[0]
    elif phase == 'train' :
        return get_output([X,0])[0]



