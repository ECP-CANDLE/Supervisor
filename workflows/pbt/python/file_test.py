import random
import sys
import time

import keras
from keras import backend as K
from mpi4py import MPI
from pbt_utils import PBTClient, PBTMetaDataStore, Timer

GET = 0
PUT = 1


def r2(y_true, y_pred):
    SS_res = K.sum(K.square(y_true - y_pred))
    SS_tot = K.sum(K.square(y_true - K.mean(y_true)))
    return 1 - SS_res / (SS_tot + K.epsilon())


def run(comm, worker_comm, model_file):
    client = PBTClient(comm, 0)
    model = keras.models.load_model(model_file, custom_objects={"r2": r2})
    timer = Timer("./timings_{}.csv".format(client.rank))

    timer.start()
    client.put_score(random.random())
    model.save_weights("./weights/weights_{}.h5".format(client.rank))
    client.release_write_lock(client.rank)
    timer.end(PUT)

    worker_comm.Barrier()

    for i in range(3):
        wait = random.uniform(1, 10)
        time.sleep(wait)

        timer.start()
        rank, score = client.get_best_score(lock_weights=True)
        model.load_weights("./weights/weights_{}.h5".format(rank))
        client.release_read_lock(rank)
        timer.end(GET)

        wait = random.uniform(1, 10)
        time.sleep(wait)
        timer.start()
        client.put_score(random.uniform(10, 100), lock_weights=True)
        model.save_weights("./weights/weights_{}.h5".format(client.rank))
        client.release_write_lock(client.rank)
        timer.end(PUT)

    timer.close()
    client.done()


def main(model_file):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    group = comm.Get_group().Excl([0])
    worker_comm = comm.Create(group)

    if rank == 0:
        data_store = PBTMetaDataStore(comm)
        data_store.run()
    else:
        run(comm, worker_comm, model_file)


if __name__ == "__main__":
    main(sys.argv[1])
