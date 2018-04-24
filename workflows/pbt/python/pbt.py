from mpi4py import MPI
import time, math

from collections import deque
import random, os.path

import keras

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


class MsgType:
    LOCKED, UNLOCKED, ACQUIRE_READ_LOCK, RELEASE_READ_LOCK, ACQUIRE_WRITE_LOCK, RELEASE_WRITE_LOCK, GET_DATA, PUT_DATA, LOG, DONE = range(10)


class Tags:
    REQUEST, ACK, SCORE = range(3)


class PBTClient:

    def __init__(self, comm, dest):
        self.comm = comm
        self.rank = comm.Get_rank()
        self.dest = dest

    def acquire_read_lock(self, for_rank):
        msg = {'type' : MsgType.ACQUIRE_READ_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        #print("{} requesting read lock: {}".format(self.rank, msg))
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
        #print("{} acquired read lock".format(self.rank))

    def release_read_lock(self, for_rank):
        msg = {'type' : MsgType.RELEASE_READ_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock release
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)

    def release_write_lock(self, for_rank):
        msg = {'type' : MsgType.RELEASE_WRITE_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock release
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)

    def get_data(self, score, lock_weights=True):
        msg = {'type' : MsgType.GET_DATA, 'lock_weights' : lock_weights, 'score': score}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        status = MPI.Status()
        result = self.comm.recv(source=self.dest, tag=Tags.SCORE, status=status)
        if len(result) and lock_weights:
                self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
                #print{"{} acquired weights lock".format(self.rank))
        return result

    def put_data(self, data, lock_weights=True):
        msg = {'type' : MsgType.PUT_DATA, 'data' : data,
               'lock_weights' : lock_weights}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # don't return until the score has actually been put
        self.comm.recv(source=self.dest, tag=Tags.ACK)
        status = MPI.Status()
        if lock_weights:
            self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
            #print{"{} acquired weights lock".format(self.rank))

    def log(self, log):
        msg = {'type': MsgType.LOG, 'log': log}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)

    def done(self):
        msg = {'type' : MsgType.DONE}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)


class DataStoreLock:

    def __init__(self, comm, source, target):
        self.source = source
        self.target = target
        self.comm = comm

    def lock(self):
        #print{"Ack for lock '{}' lock from {}".format(self.locked_obj, self.target))
        # send the acknowledgement of the lock back to target
        self.comm.send(MsgType.LOCKED, dest=self.target, tag=Tags.ACK)

    def unlock(self):
        #print{"Ack for unlock '{}' lock from {}".format(self.locked_obj, self.target))
        self.comm.send(MsgType.UNLOCKED, dest=self.target, tag=Tags.ACK)


class DataStoreLockManager:

    def __init__(self, comm, rank):
        self.rank = rank
        self.comm = comm
        self.readers = {}
        self.queued_readers = deque()
        self.queued_writers = deque()
        self.writer = None

    def read_lock(self, requesting_rank):
        # if writer, then queue the read
        # else add DataStoreLock to readers, and call locks
        lock = DataStoreLock(self.comm, self.rank, requesting_rank)
        if self.writer != None:
            self.queued_readers.append(lock)
        else:
            self.readers[requesting_rank] = lock
            lock.lock()

    def read_unlock(self, requesting_rank):
        # look up Lock in readers and send unlock and remove from readers
        # if readers is empty, then lock first queued writer and set self.write
        lock = self.readers.pop(requesting_rank)
        lock.unlock()
        if len(self.readers) == 0 and len(self.queued_writers) > 0:
            self.writer = self.queued_writers.popleft()
            self.writer.lock()

    def write_lock(self, requesting_rank):
        # if no readers and self.writer = None then set self.writer
        # else add to queued writers
        lock = DataStoreLock(self.comm, self.rank, requesting_rank)
        if len(self.readers) == 0 and self.writer == None:
            self.writer = lock
            lock.lock()
        else:
            self.queued_writers.append(lock)

    def write_unlock(self, requesting_rank):
        # unlock self.writer (shouldn't be None!), set to None
        # if queued readers then lock those, else check queued writers
        # and lock first for those
        if self.writer.target != requesting_rank:
            print("bad write unlock")

        self.writer.unlock()
        self.writer = None
        if len(self.queued_readers) > 0:
            for lock in self.queued_readers:
                lock.lock()
                self.readers[lock.target] = lock
            self.queued_readers = deque()

        elif len(self.queued_writers) > 0:
            self.writer = queued_writers.popleft()
            self.writer.lock()


class PBTMetaDataStore:

    DUMMY_RANK = -9999

    def __init__(self, comm, outdir, exploiter, log_file):
        self.locks = {}
        self.comm = comm
        self.rank = self.comm.Get_rank()
        self.scores = {}
        self.outdir = outdir
        self.exploiter = exploiter
        for i in range(self.comm.Get_size()):
            if i != self.rank:
                self.locks[i] = DataStoreLockManager(self.comm, self.rank)
                self.scores[i] = {'score': float('nan')}
        self.log_file = log_file
        self.all_scores = []
        self.logs = []

    def write_data(self):
        if len(self.all_scores):
            f = "{}/output.csv".format(self.outdir)
            header = self.all_scores[0].keys()
            if not os.path.isfile(f):
                with open(f, 'w') as f_out:
                    f_out.write(",".join(header))
                    f_out.write("\n")

            with open(f, 'a') as f_out:
                for item in self.all_scores:
                    for i, h in enumerate(header):
                        if i > 0:
                            f_out.write(",")
                        f_out.write("{}".format(item[h]))
                    f_out.write("\n")

            self.all_scores = []

    def done(self):
        self.write_logs()
        self.write_data()

    def write_logs(self):
        with open(self.log_file, 'a') as f_out:
            for l in self.logs:
                f_out.write(l)
                f_out.write("\n")

        self.logs = []

    def acquire_read_lock(self, requesting_rank, key):
        #print("{} acquiring read lock for {}".format(requesting_rank, key))
        lock_manager = self.locks[key]
        lock_manager.read_lock(requesting_rank)

    def release_read_lock(self, requesting_rank, key):
        #print("{} releasing read lock for {}".format(requesting_rank, key))
        # can get NULL_RANK if score requested but no scores yet
        lock_manager = self.locks[key]
        lock_manager.read_unlock(requesting_rank)

    def acquire_write_lock(self, requesting_rank, key):
        #print("{} acquiring write lock for {}".format(requesting_rank, key))
        lock_manager = self.locks[key]
        lock_manager.write_lock(requesting_rank)

    def release_write_lock(self, requesting_rank, key):
        #print("{} releasing write lock for {}".format(requesting_rank, key))
        lock_manager = self.locks[key]
        lock_manager.write_unlock(requesting_rank)

    def put_data(self, putting_rank, data):
        """
            :param :data - dictionary of data: val_loss etc.
        """
        #print("Putting score {},{}".format(putting_rank, data))
        self.all_scores.append(data)

        live_ranks = self.comm.Get_size() - 1
        if len(self.all_scores) == live_ranks:
            self.write_data()
        self.scores[putting_rank] = data
        self.comm.send(MsgType.PUT_DATA, tag=Tags.ACK, dest=putting_rank)

    def get_data(self, score):
        items = [x for x in self.scores.values() if not math.isnan(x['score'])]
        result = self.exploiter(items, score)
        return result

    def run(self):
        status = MPI.Status()
        live_ranks = self.comm.Get_size() - 1
        while live_ranks > 0:
            msg = self.comm.recv(source=MPI.ANY_SOURCE, tag=Tags.REQUEST, status=status)
            source = status.Get_source()
            msg_type = msg['type']

            if msg_type == MsgType.ACQUIRE_READ_LOCK:
                msg_rank = msg['rank']
                self.acquire_read_lock(source, msg_rank)

            elif msg_type == MsgType.RELEASE_READ_LOCK:
                msg_rank = msg['rank']
                self.release_read_lock(source, msg_rank)

            elif msg_type == MsgType.RELEASE_WRITE_LOCK:
                msg_rank = msg['rank']
                self.release_write_lock(source, msg_rank)

            elif msg_type == MsgType.PUT_DATA:
                data = msg['data']
                lock_weights = msg['lock_weights']
                self.put_data(source, data)
                if lock_weights:
                    self.acquire_write_lock(source, source)

            elif msg_type == MsgType.GET_DATA:
                score = msg['score']
                result = self.get_data(score)
                self.comm.send(result, dest=source, tag=Tags.SCORE)

                lock_weights = msg['lock_weights']
                if len(result) and lock_weights:
                    rank_to_read = result['rank']
                    self.acquire_read_lock(source, rank_to_read)

            elif msg_type == MsgType.LOG:
                log = msg['log']
                self.logs.append(log)
                if len(self.logs) > 100:
                    self.write_logs()

            elif msg_type == MsgType.DONE:
                live_ranks -= 1

        self.done()

        print("Done")


class PBTCallback(keras.callbacks.Callback):

    GET = 0
    PUT = 1

    def __init__(self, comm, root_rank, outdir, model_worker):
        self.client = PBTClient(comm, root_rank)
        self.outdir = outdir
        #self.timer = Timer("{}/timings_{}.csv".format(self.outdir, self.client.rank))
        self.model_worker = model_worker

    def on_batch_end(self, batch, logs):
        pass

    def on_epoch_end(self, epoch, logs):
        metrics = {'epoch': epoch, 'rank': self.client.rank}
        metrics.update(logs)
        data = self.model_worker.pack_data(self.client, self.model, metrics)
        self.client.put_data(data)
        self.model.save_weights("{}/weights_{}.h5".format(self.outdir,
                                                          self.client.rank))
        self.client.release_write_lock(self.client.rank)
        #self.timer.end(PBTCallback.PUT)

        if self.model_worker.ready(self.client, epoch):
            result = self.client.get_data(data['score'])
            if len(result):
                print("\n{},{} is ready - updating".format(epoch, self.client.rank))
                rank_to_read = result['rank']
                self.model_worker.update(epoch, self.client, self.model, result)
                #print("{} loading weights from {}".format(self.client.rank, rank))
                self.model.load_weights("{}/weights_{}.h5".format(self.outdir,
                                                            rank_to_read))
                self.client.release_read_lock(rank_to_read)
            else:
                print("\n{},{} is ready - no update".format(epoch, self.client.rank))

    def on_train_end(self, logs={}):
        self.client.done()
