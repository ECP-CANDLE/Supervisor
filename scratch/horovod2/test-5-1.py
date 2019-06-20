
# TEST 5-1

from __future__ import print_function

print("TEST 5-1 PY")

import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
import math
import tensorflow as tf
import horovod.keras as hvd

# Horovod: initialize Horovod.
hvd.init()
