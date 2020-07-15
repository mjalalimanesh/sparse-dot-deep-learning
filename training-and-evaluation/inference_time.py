# -*- coding: utf-8 -*-
"""
Created on Wed Jul 15 13:59:38 2020

@author: Mohamad Jalali Manesh
"""

import tensorflow as tf
import numpy as np

print(tf.__version__)

model = tf.keras.models.load_model('new_noisy.h5')
inputt = np.ones((1,29))*2

from timeit import default_timer as timer

start = timer()
res = model.predict(inputt)
end = timer()
print(end - start) # Time in seconds, e.g. 5.38091952400282
