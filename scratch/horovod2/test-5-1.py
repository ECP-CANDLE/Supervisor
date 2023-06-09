# TEST 5-1

from __future__ import print_function

print("TEST 5-1 PY")

import math

import horovod.keras as hvd
import keras
import tensorflow as tf
from keras import backend as K
from keras.datasets import mnist
from keras.layers import Conv2D, Dense, Dropout, Flatten, MaxPooling2D
from keras.models import Sequential

# Horovod: initialize Horovod.
hvd.init()
