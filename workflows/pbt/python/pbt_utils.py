from mpi4py import MPI
import ctypes
from timer import Timer

import StringIO

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

    def get_data(self, rank):
        return self.items[rank]

class PBTDataSpaces:

    def __init__(self):
        self.lib = ctypes.cdll.LoadLibrary("./libpbt_ds.so")
        # different mpi implementation use different types for
        # MPI_Comm, this determines which type to use
        if MPI._sizeof(MPI.Comm) == ctypes.sizeof(ctypes.c_int):
            self.mpi_comm_type = ctypes.c_int
        else:
            self.mpi_comm_type = ctypes.c_void_p

        self.mpi_comm_self = self.make_comm_arg(MPI.COMM_SELF)
        self.mpi_comm_world = self.make_comm_arg(MPI.COMM_WORLD)
        self.rank = MPI.COMM_WORLD.Get_rank()
        self.world_size = MPI.COMM_WORLD.Get_size()

    def make_comm_arg(self, comm):
        comm_ptr = MPI._addressof(comm)
        comm_val = self.mpi_comm_type.from_address(comm_ptr)
        return comm_val

    def init_ds(self):
        self.lib.pbt_ds_init(self.mpi_comm_world, ctypes.c_int(self.world_size))

    def init_scores(self):
        self.lib.pbt_ds_define_score_dim(self.world_size)
        self.lib.pbt_ds_put_score(self.rank, ctypes.c_double(0.0),
                            ctypes.c_double(0.0), self.mpi_comm_self)

    def put_weights(self, pickled_weights, score):
        weights_size = len(pickled_weights)
        print("Putting Scores")
        t = Timer()
        t.start()
        self.lib.pbt_ds_put_score(self.rank, ctypes.c_double(score),
                                ctypes.c_double(weights_size), self.mpi_comm_self)
        t.start()
        print("Putting Weights")
        self.lib.pbt_ds_put_weights(self.rank, pickled_weights, weights_size, self.mpi_comm_self)
        t.end("Put Weights")

    def get_weights(self, model_data):
        size = int(model_data.size)
        data = ctypes.create_string_buffer(size)
        t = Timer()
        t.start()
        self.lib.pbt_ds_get_weights(model_data.rank, data, size, self.mpi_comm_self)
        t.end("Got Weights")
        return StringIO(data)

    def get_model_data(self):
        size = 2 * self.world_size
        # do NOT do "ctypes.c_double * 2 * self.world_size"!
        # that creates something else entirely!
        data = (ctypes.c_double * size)()
        self.lib.pbt_ds_get_all_scores(self.world_size, data, self.mpi_comm_self)
        return ModelData(data)
