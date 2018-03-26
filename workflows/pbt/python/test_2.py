from mpi4py import MPI
import sys, time, random

import cPickle, pickle, StringIO

import keras
from keras.models import Sequential
from keras import backend as K
from keras.layers import Dense, Activation

from pbt_utils import PBTDataSpaces, Timer


GET = 0
PUT = 1


def r2(y_true, y_pred):
    SS_res =  K.sum(K.square(y_true - y_pred))
    SS_tot = K.sum(K.square(y_true - K.mean(y_true)))
    return (1 - SS_res/(SS_tot + K.epsilon()))

def main():
    pbt_ds = PBTDataSpaces()
    pbt_ds.init_ds()
    pbt_ds.init_scores()

    rank = MPI.COMM_WORLD.Get_rank()
    timer = Timer("./timings_{}.csv".format(rank))
    model = keras.models.load_model("./models/combo_model.h5", custom_objects={'r2' : r2})

    timer.start()
    weights = cPickle.dumps(model.get_weights(), pickle.HIGHEST_PROTOCOL)
    fake_score = random.uniform(10, 100)
    pbt_ds.put_weights(weights, fake_score)
    timer.end(PUT)

    MPI.COMM_WORLD.Barrier()

    for i in range(3):
        wait = random.uniform(1, 10)
        time.sleep(wait)

        data = pbt_ds.get_model_data()
        max_data = data.max()
        print("Max: {}".format(max_data))
        timer.start()
        weights = cPickle.load(pbt_ds.get_weights(max_data))
        timer.end(GET)
        model.set_weights(weights)

        wait = random.uniform(1, 10)
        time.sleep(wait)

        timer.start()
        weights = cPickle.dumps(model.get_weights(), pickle.HIGHEST_PROTOCOL)
        fake_score = random.uniform(10, 100)
        pbt_ds.put_weights(weights, fake_score)
        timer.end(PUT)

    timer.close()
    pbt_ds.finalize()
    print("Done")

if __name__ == '__main__':
    main()
