from mpi4py import MPI

from keras.models import Sequential
from keras.layers import Dense, Activation

import cPickle, ctypes, pickle
from cStringIO import StringIO

SCORES_VAR = "scores"

MPI_Comm_type = None

class ModelMetaData:
    def __init__(self, rank, score, size):
        self.rank = rank
        self.size = size
        self.score = score

    def __str__(self):
        return "ModelMetaData[rank: {}, size: {}, score: {}]".format(self.rank,
                                                                     self.size,
                                                                     self.score)

class ModelData:

    def __init__(self, data):
        """
        data - ctypes c_double array of score, size, score, size ...
        ordered by rank
        """
        self.items = []
        self.max_ranks = []
        max_score = float('-inf')
        rank = 0
        for i in xrange(0,len(data), 2):
            score = data[i]
            size = data[i + 1]
            md = ModelMetaData(rank, score, size)
            self.items.append(md)
            if score > max_score:
                self.max_ranks = [rank]
                max_score = score
            elif score == max_score:
                self.max_ranks.append(rank)

            rank += 1

    def max(self):
        return self.items[self.max_ranks[0]]


def create_model():
    model = Sequential([
        Dense(32, input_shape=(784,)),
        Activation('relu'),
        Dense(10),
        Activation('softmax'),
    ])
    return model

def pickle_model(model):
    s = cPickle.dumps(model.get_weights(), pickle.HIGHEST_PROTOCOL)
    #s = s.encode()
    return s

def init_lib():
    global MPI_Comm_type
    lib = ctypes.cdll.LoadLibrary("./libpbt_ds.so")
    if MPI._sizeof(MPI.Comm) == ctypes.sizeof(ctypes.c_int):
        MPI_Comm_type = ctypes.c_int
    else:
        MPI_Comm_type = ctypes.c_void_p
    lib.pbt_ds_init.argtypes = [MPI_Comm_type, ctypes.c_int]

    return lib

def make_comm_arg(comm):
    comm_ptr = MPI._addressof(comm)
    comm_val = MPI_Comm_type.from_address(comm_ptr)
    return comm_val

def init_ds(rank, lib):
    nprocs = MPI.COMM_WORLD.Get_size()
    comm_val = make_comm_arg(MPI.COMM_WORLD)
    lib.pbt_ds_init(comm_val, ctypes.c_int(nprocs))

def init_scores(rank, nprocs, lib):
    lib.pbt_ds_define_score_dim(nprocs)
    comm = make_comm_arg(MPI.COMM_SELF)
    lib.pbt_ds_put_score(rank, ctypes.c_double(0.0),
                        ctypes.c_double(0.0), comm)

def put_weights(rank, model, lib):
    s = pickle_model(model)
    comm = make_comm_arg(MPI.COMM_SELF)
    fake_score = (10 - rank) * 1.23
    lib.pbt_ds_put_score(rank, ctypes.c_double(fake_score), ctypes.c_double(len(s)), comm)
    lib.pbt_ds_put_weights(rank, s, len(s), comm)

def get_weights(model_data, lib):
    size = int(model_data.size)
    data = ctypes.create_string_buffer(size)
    comm = make_comm_arg(MPI.COMM_SELF)
    lib.pbt_ds_get_weights(model_data.rank, data, size, comm)
    return cPickle.load(StringIO(data))

def get_model_data(nprocs, lib):
    size = 2 * nprocs
    # do NOT do "ctypes.c_double * 2 * nprocs"!
    # that creates something else entirely!
    data = (ctypes.c_double * size)()
    comm = make_comm_arg(MPI.COMM_SELF)
    lib.pbt_ds_get_all_scores(nprocs, data, comm)
    return ModelData(data)

def main():
    lib = init_lib()
    comm = MPI.COMM_WORLD
    # could also use dataspaces rank here, maybe
    rank = comm.Get_rank()
    nprocs = comm.Get_size()

    init_ds(rank, lib)

    # the pickeled size is not constant, so this
    # needs to be changed
    model = create_model()
    init_scores(rank, comm.Get_size(), lib)

    put_weights(rank, model, lib)

    comm.Barrier()

    if (rank == 1):
        data = get_model_data(nprocs, lib)
        max_data = data.max()
        print("Max: {}".format(max_data))
        weights = get_weights(max_data, lib)
        print(weights)
        model.set_weights(weights)

    comm.Barrier()
    lib.pbt_ds_finalize()

if __name__ == '__main__':
    main()
