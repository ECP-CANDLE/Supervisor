from mpi4py import MPI
import numpy as np
from timer import Timer
import sys

import cPickle, pickle

import keras
from keras.models import Sequential

from keras.layers import Dense, Activation
from pbt_utils import PBTDataSpaces

import StringIO


def create_model():
    model = Sequential([
        Dense(32, input_shape=(784,)),
        Activation('relu'),
        Dense(10),
        Activation('softmax'),
    ])

    return model

def main():
    pbt_ds = PBTDataSpaces()
    pbt_ds.init_ds()
    pbt_ds.init_scores()

    rank = MPI.COMM_WORLD.Get_rank()
    model = create_model()
    weights = cPickle.dumps(model.get_weights(), pickle.HIGHEST_PROTOCOL)
    fake_score = (10 - rank) * 1.23

    pbt_ds.put_weights(weights, fake_score)
    MPI.COMM_WORLD.Barrier()

    if rank == 1:
        # test that one rank get another's weights and use them
        data = pbt_ds.get_model_data()
        max_data = data.max()
        print("Max: {}".format(max_data))
        weights = cPickle.load(pbt_ds.get_weights(max_data))
        model.set_weights(weights)

    elif rank == 0:
        # test that rank 0's weights are identical to the stored
        # weights for rank 0
        data = data = pbt_ds.get_model_data()
        zero_data = data.get_data(0)
        stored_weights = cPickle.load(pbt_ds.get_weights(zero_data))
        weights = model.get_weights()
        passed = len(weights) == len(stored_weights)
        if passed:
            for i,ar in enumerate(stored_weights):
                passed = np.array_equal(weights[i], ar)

        print("Passed: {}".format(passed))

    MPI.COMM_WORLD.Barrier()
    pbt_ds.finalize()
    print("Done")

if __name__ == '__main__':
    main()
