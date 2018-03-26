from mpi4py import MPI
import ctypes, time

from cStringIO import StringIO

from collections import deque
import random

class Timer:

    def __init__(self, fname=None):
        if fname == None:
            self.out = None
        else:
            self.out = open(fname, 'w')


    def start(self):
        self.t = time.time()

    def end(self, msg):
        duration = time.time() - self.t
        line = "{},{},{},{}".format(msg, self.t, time.time(), duration)
        if self.out != None:
            self.out.write("{}\n".format(line))
        else:
            print(line)

    def close(self):
        if self.out != None:
            self.out.close()

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
        self.lib.pbt_ds_init(ctypes.c_int(self.world_size), self.mpi_comm_world)

    def init_scores(self):
        self.lib.pbt_ds_define_score_dim(self.world_size)
        self.lib.pbt_ds_put_score(self.rank, ctypes.c_double(0.0),
                            ctypes.c_double(0.0), self.mpi_comm_self)

    def put_weights(self, pickled_weights, score):
        weights_size = len(pickled_weights)
        self.lib.pbt_ds_put_score(self.rank, ctypes.c_double(score),
                                ctypes.c_double(weights_size), self.mpi_comm_self)
        self.lib.pbt_ds_put_weights(self.rank, pickled_weights, weights_size, self.mpi_comm_self)

    def get_weights(self, model_data):
        size = int(model_data.size)
        data = ctypes.create_string_buffer(size)
        self.lib.pbt_ds_get_weights(model_data.rank, data, size, self.mpi_comm_self)
        return StringIO(data)

    def get_model_data(self):
        size = 2 * self.world_size
        # do NOT do "ctypes.c_double * 2 * self.world_size"!
        # that creates something else entirely!
        data = (ctypes.c_double * size)()
        self.lib.pbt_ds_get_all_scores(self.world_size, data, self.mpi_comm_self)
        return ModelData(data)

    def finalize(self):
        self.lib.pbt_ds_finalize()


class MsgType:
    ACQUIRE_WRITE_LOCK, RELEASE_WRITE_LOCK, GET_BEST_SCORE, PUT_SCORE, DONE = range(5)


class Tags:
    REQUEST, ACK, SCORE = range(3)


class PBTClient:

    def __init__(self, comm, dest):
        self.comm = comm
        self.rank = comm.Get_rank()
        self.dest = dest

    def acquire_lock(self, for_rank):
        msg = {'type' : MsgType.ACQUIRE_WRITE_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        #print("{} requesting weights lock: {}".format(self.rank, msg))
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
        #print("{} acquired weights lock".format(self.rank))

    def release_lock(self, for_rank):
        msg = {'type' : MsgType.RELEASE_WRITE_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock release
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)

    def get_best_score(self, lock_weights=True):
        msg = {'type' : MsgType.GET_BEST_SCORE, 'lock_weights' : lock_weights}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        status = MPI.Status()
        if lock_weights:
            self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
            #print{"{} acquired weights lock".format(self.rank))

        score_rank = self.comm.recv(source=self.dest, tag=Tags.SCORE, status=status)
        return score_rank

    def put_score(self, score, lock_weights=True):
        msg = {'type' : MsgType.PUT_SCORE, 'score' : score,
               'lock_weights' : lock_weights}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # don't return until the score has actually been put
        self.comm.recv(source=self.dest, tag=Tags.ACK)
        status = MPI.Status()
        if lock_weights:
            self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
            #print{"{} acquired weights lock".format(self.rank))

    def done(self):
        msg = {'type' : MsgType.DONE}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)


class DataStoreLock:

    def __init__(self, comm, source, target, locked_obj):
        self.source = source
        self.target = target
        self.locked_obj = locked_obj
        self.comm = comm

    def lock(self):
        #print{"Ack for lock '{}' lock from {}".format(self.locked_obj, self.target))
        # send the acknowledgement of the lock back to target
        self.comm.send(MsgType.ACQUIRE_WRITE_LOCK, dest=self.target, tag=Tags.ACK)

    def unlock(self):
        #print{"Ack for unlock '{}' lock from {}".format(self.locked_obj, self.target))
        self.comm.send(MsgType.RELEASE_WRITE_LOCK, dest=self.target, tag=Tags.ACK)


class PBTMetaDataStore:

    def __init__(self, comm):
        self.locks = {}
        self.comm = comm
        self.rank = self.comm.Get_rank()
        self.scores = {}

    def acquire_lock(self, requesting_rank, key):
        lock = DataStoreLock(self.comm, self.rank, requesting_rank, key)
        if key in self.locks:
            # assumes that the dequeue will never be empty
            # an empty deque should be removed from the dict.
            deq = self.locks[key]
            deq.append(lock)
        else:
            self.locks[key] = deque([lock])
            lock.lock()

    def release_lock(self, key):
        if key not in self.locks or len(self.locks[key]) == 0:
            print("Bad release lock request. No lock found: {}".format(key))
            return

        deq = self.locks[key]
        lock = deq.popleft()
        lock.unlock()

        if len(deq) == 0:
            # remove the deque
            del self.locks[key]
        else:
            deq[0].lock()

    def get_best_score(self, requesting_rank):
        # use min, expecting val_loss
        mins = []
        val = float('inf')
        for k in self.scores:
            score = self.scores[k]
            if score < val:
                mins = []
                val = score
                mins.append(k)
            elif score == val:
                mins.append(k)

        return (random.choice(mins), val)


    def put_score(self, putting_rank, score):
        #print("Putting score {},{}".format(putting_rank, score))
        self.scores[putting_rank] = score
        self.comm.send(MsgType.PUT_SCORE, tag=Tags.ACK, dest=putting_rank)

    def run(self):
        status = MPI.Status()
        live_ranks = self.comm.Get_size() - 1
        while live_ranks > 0:
            msg = self.comm.recv(source=MPI.ANY_SOURCE, tag=Tags.REQUEST, status=status)
            source = status.Get_source()
            msg_type = msg['type']

            if msg_type == MsgType.ACQUIRE_WRITE_LOCK:
                msg_rank = msg['rank']
                key = "weights{}".format(msg_rank)
                self.acquire_lock(source, key)

            elif msg_type == MsgType.RELEASE_WRITE_LOCK:
                msg_rank = msg['rank']
                key = "weights{}".format(msg_rank)
                self.release_lock(key)

            elif msg_type == MsgType.PUT_SCORE:
                score = msg['score']
                lock_weights = msg['lock_weights']
                self.put_score(source, score)
                if lock_weights:
                    key = "weights{}".format(source)
                    self.acquire_lock(source, key)

            elif msg_type == MsgType.GET_BEST_SCORE:
                rank, score = self.get_best_score(source)
                lock_weights = msg['lock_weights']
                if lock_weights:
                    key = "weights{}".format(rank)
                    self.acquire_lock(source, key)

                self.comm.send((rank,score), dest=source, tag=Tags.SCORE)

            elif msg_type == MsgType.DONE:
                live_ranks -= 1

        print("Done")
