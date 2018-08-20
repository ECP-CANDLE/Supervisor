from mpi4py import MPI
import time, math, ctypes

from collections import deque
import random, os.path

import keras

try:
    import cPickle as pkl
except ImportError:
    import pickle as pkl

try:
    from StringIO import StringIO as IO
except ImportError:
    from io import BytesIO as IO



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
    """Client of the PBTMetaDataStore, used to request locks, and put and get data
    from a PBTMetaDataStore.
    """

    def __init__(self, comm, dest, outdir):
        """Initializes the PBT client with a communicator and the destination rank
        of the PBTMetaDataStore

        :param comm: the communicator to use to send / recv messages to the PBTMetaDataStore
        :param dest: the rank of the PBTMetaDataStore
        """
        self.comm = comm
        self.rank = comm.Get_rank()
        self.dest = dest
        self.outdir = outdir

    def acquire_read_lock(self, for_rank):
        """Acquries a read lock the weights file for the specified rank.

        This method will return when the read lock has been acquired. After
        the file has been read, the lock must be released by calling the
        'release_read_lock' method.

        :param for_rank: the rank of the weights file to acquire the lock for.
        """
        msg = {'type' : MsgType.ACQUIRE_READ_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        #print("{} requesting read lock: {}".format(self.rank, msg))
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
        #print("{} acquired read lock".format(self.rank))

    def release_read_lock(self, for_rank):
        """Releases a previously acquired read lock for the weights file
        produced by the specified rank.

        :param for_rank:  the rank of the weights file to release the lock for.
        """
        msg = {'type' : MsgType.RELEASE_READ_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock release
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)

    def release_write_lock(self, for_rank):
        """Releases the write lock for the specified rank that has been acquired
        by the put_data call.

        :param for_rank: the rank of the weights file to release the write lock for.
        """

        msg = {'type' : MsgType.RELEASE_WRITE_LOCK, 'rank' : for_rank}
        status = MPI.Status()
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        # wait for acknowledgement of lock release
        self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)

    def get_data(self, score, lock_weights=True):
        """Gets the metadata for a better performing model, assuming there is one.

        Given a score against which to evaluate model performance, this will return
        the metadata for a better performing model as dictionary. If there is no better
        performing model, then this returns an empty dictionary. Note that the algorithm that
        evaluates model performance is passed into the PBTMetaDataStore in its
        constructor.

        :param score: a float against which the peformance of the calling model
        is evaluated with respect to the other models.
        :param lock_weights: if True, then this method will also lock the weights file
        for the rank returned in the results dictionary.
        :returns: a dictionary with the metadata of the better performing model.
        The dictionary will contain whatever the model client code puts in the
        data store. By default, this is the accuracy ('acc'), loss ('loss'),
        rank of the model that produced this metadata ('rank'), validation accuracy
        ('val_acc'), validation loss ('val_loss'), and the score used to evaluate
         a model's performance ('score'). The dictionary will also contain whatever
         model hyperparameters client code puts in the datastore.
        """
        msg = {'type' : MsgType.GET_DATA, 'lock_weights' : lock_weights, 'score': score}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)
        status = MPI.Status()
        result = self.comm.recv(source=self.dest, tag=Tags.SCORE, status=status)
        if len(result) and lock_weights:
                self.comm.recv(source=self.dest, tag=Tags.ACK, status=status)
                #print{"{} acquired weights lock".format(self.rank))
        return result

    def put_data(self, data, lock_weights=True):
        """Puts the specified data in the PBTMetaDataStore.

        The data must be a dictionary that include at the very least a
        'score' key with a float value used to evaluate model performance, and
        the rank of the model whose score it is.

        :param data: the a dictionary to put in the metadatastore.
        :param lock_weights: if True this method will also acquire the write lock
        for the weights file associated with the rank in the data dictionary.
        """
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
        """Logs the specified log message.
        """
        msg = {'type': MsgType.LOG, 'log': log}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)

    def done(self):
        """Notifies the PBTMetaDataStore that model associated with this PBTClient
        is finished.

        No more PBTClient calls should be made after this method is called.
        """
        msg = {'type' : MsgType.DONE}
        self.comm.send(msg, dest=self.dest, tag=Tags.REQUEST)


    def put(self, data, model):
        self.put_data(data)
        model.save_weights("{}/weights_{}.h5".format(self.outdir, self.rank))
        self.release_write_lock(self.rank)

    def load_weights(self, model, data, read_rank):
        model.load_weights("{}/weights_{}.h5".format(self.outdir, read_rank))
        self.release_read_lock(read_rank)

class DataSpacesPBTClient(PBTClient):

    def __init__(self, comm, dest, outdir):
        # For python 2 compatibility
        super(DataSpacesPBTClient, self).__init__(comm, dest, outdir)
        path = os.path.dirname(os.path.abspath(__file__))
        self.lib = ctypes.cdll.LoadLibrary("{}/libpbt_ds.so".format(path))
        # different mpi implementation use different types for
        # MPI_Comm, this determines which type to use
        if MPI._sizeof(MPI.Comm) == ctypes.sizeof(ctypes.c_int):
            self.mpi_comm_type = ctypes.c_int
        else:
            self.mpi_comm_type = ctypes.c_void_p

        group = comm.Get_group()
        newgroup = group.Excl([dest])
        ds_comm = comm.Create(newgroup)

        self.mpi_comm_self = self.make_comm_arg(MPI.COMM_SELF)
        mpi_comm_ds = self.make_comm_arg(ds_comm)
        world_size = ds_comm.Get_size()
        self.lib.pbt_ds_init(ctypes.c_int(world_size), mpi_comm_ds)

    def make_comm_arg(self, comm):
        comm_ptr = MPI._addressof(comm)
        comm_val = self.mpi_comm_type.from_address(comm_ptr)
        return comm_val

    def put(self, data, model):
        weights = pkl.dumps(model.get_weights(), pkl.HIGHEST_PROTOCOL)
        weights_size = len(weights)
        data['_weights_size_'] = weights_size
        self.put_data(data)
        self.lib.pbt_ds_put_weights(self.rank, weights, weights_size, self.mpi_comm_self)
        self.release_write_lock(self.rank)

    def load_weights(self, model, data, read_rank):
        weights_size = data['_weights_size_']
        str_weights = ctypes.create_string_buffer(weights_size)
        self.lib.pbt_ds_get_weights(read_rank, str_weights, weights_size, self.mpi_comm_self)
        model.set_weights(pkl.load(IO(str_weights)))
        self.release_read_lock(read_rank)

    def done(self):
        # For python 2 compatibility
        super(DataSpacesPBTClient, self).done()
        self.lib.pbt_ds_finalize()


class DataStoreLock:
    """Lock for an individual weights file.
    """

    def __init__(self, comm, source, target):
        """

        :param comm: the MPI communicator
        :param source: the rank requesting the lock
        :param target: the rank of the weights file to lock
        """
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

    def __init__(self, comm, outdir, exploiter, log_file, dataspaces=False):
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

        if dataspaces:
            # PBTClient's perform this collective action so it needs to
            # be done here as well.
            group = comm.Get_group()
            newgroup = group.Excl([self.rank])
            ds_comm = comm.Create(newgroup)

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
        t = time.localtime()
        start_time = time.time()
        self.logs.append("PBT Start: {}".format(time.strftime('%Y-%m-%d %H:%M:%S', t)))
        self.write_logs()
        
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
                if len(self.logs) > 20:
                    self.write_logs()

            elif msg_type == MsgType.DONE:
                live_ranks -= 1

        
        t = time.localtime()
        self.logs.append("PBT End: {}".format(time.strftime('%Y-%m-%d %H:%M:%S', t)))
        self.logs.append("Duration: {}".format(time.time() - start_time))
        self.done()

        print("Done")
        

class PBTWorker:
    """  PBTCallback uses classes that implement this API to determine
    when a model is ready to exploit and explore, to retrieve metadata
    and hyperparameters from the model to put in the shared PBTMetaDataStore,
    and to perform the model specific exploit and explore update.
    """

    def ready(self, pbt_client, epoch, model):
        """ Returns True if the model is ready for an exploit explore update.

        :param pbt_client: A PBTClient instance that can be used for logging (i.e.
        pbt_client.log(msg))
        :param epoch: the current epoch
        :param model: the NN model associated with this PBTWorker.
        """
        pass

    def pack_data(self, pbt_client, model, metrics):
        """ Packs relevant hyperparameters and selected score metric into a dict to be
        passed to the PBTMetaDataStore. A typical implementation will select
        one of the metrics (e.g. 'val_loss') from the keras provided metrics
        and set that as the 'score' used to determine model peformance.

        Any hyperparameters that are updated in an exploit / explore should
        also be included in the returned dictionary. For example,

        # get the current learning rate
        lr = float(K.get_value(model.optimizer.lr))
        data = {'lr': lr, 'score': metrics['val_loss']}
        data.update(metrics)
        return data

        :param pbt_client: A PBTClient instance that can be used for logging (i.e.
        pbt_client.log(msg))
        :param model: the NN model associated with this PBTWorker.
        :param metrics: the metrics in a keras callback log (i.e 'acc',
        'val_acc', 'val_loss')
        :return a dictionary containing the peformance metadata and hyperameters
        to store for the specified model in the PBTMetaDataStore
        """
        pass

    def update(self, epoch, pbt_client, model, data):
        """ Updates the specified model by performing an exploit / explore
        using the data in data. NOTE that the PBTCallback will load the
        new weights into the model. That should NOT be done here.

        For example, assuming the pack_data method stores the learing rate as
        'lr' and we want to update the specified model's lr to a perturbed
        version of that, the following code be used here:

        current_lr = float(K.get_value(model.optimizer.lr))
        lr = data['lr']
        draw = random.random()
        if draw < .5:
            lr = lr * 0.8
        else:
            lr = lr * 1.2
        K.set_value(model.optimizer.lr, lr)

        :param epoch: the current epoch
        :param pbt_client: A PBTClient instance that can be used for logging (i.e.
        pbt_client.log(msg))
        :param data: the performance metadata and hyperparameters to use to update
        the specfiied model (i.e 'acc', 'val_acc', 'val_loss', plus any hyperparameters
        included in the data produced by the pack_data method).
        """
        pass

import traceback


class PBTCallback(keras.callbacks.Callback):
    """Implements PBT via keras callback.

    Given a :param metrics: the metrics in a keras callback log (i.e 'acc',
    'val_acc', 'val_loss') instance in its constructor, every epoch, this callback will use that
    PBTWorker to retrieve the current performance metadata for a model,
    this will put that performance metadata into a PBTMetaDataStore and write
    the model's weights out to a file.

    When the PBTWorker signifies that it is ready, that model's performance
    will be evaluated against that of other models. If a better performing model
    is found, then this callback's model will be updated with the hyperparameters of the
    better performing model via a call to `pbt_worker.update` and the better
    performing weights will be loaded into this callback's model.
    """

    GET = 0
    PUT = 1

    def __init__(self, comm, root_rank, outdir, pbt_worker, dataspaces=False):
        """ Initializes this PBTCallback.

        :param comm: the MPI communicator in which this PBTCallback operates
        :param root_rank: the rank of the PBTMetaDataStore
        :param outdir: the directory into which model weights will be written
        :param pbt_worker: A class that implements the PBTWorker API.
        """
        if dataspaces:
           self.client = DataSpacesPBTClient(comm, root_rank, outdir)
        else:
           self.client = PBTClient(comm, root_rank, outdir)

        self.outdir = outdir
        #self.timer = Timer("{}/timings_{}.csv".format(self.outdir, self.client.rank))
        self.pbt_worker = pbt_worker

    def on_batch_end(self, batch, logs):
        pass

    def on_epoch_begin(self, epoch, logs):
        
        t = time.localtime()
        self.client.log("Client {} Epoch {} Start: {}".format(self.client.rank, epoch, time.strftime('%Y-%m-%d %H:%M:%S', t)))
       
        self.epoch_start = time.time()

    def on_epoch_end(self, epoch, logs):
        metrics = {'epoch': epoch, 'rank': self.client.rank, 'duration' : time.time() - self.epoch_start}
        #print("Rank: {}, Epoch: {} end".format(self.client.rank, epoch))
        metrics.update(logs)
        data = self.pbt_worker.pack_data(self.client, self.model, metrics)
        self.client.put(data, self.model)
        #self.timer.end(PBTCallback.PUT)

        if self.pbt_worker.ready(self.client, self.model, epoch):
            result = self.client.get_data(data['score'])
            if len(result):
                print("{},{} is ready - updating".format(epoch, self.client.rank))
                rank_to_read = result['rank']
                self.pbt_worker.update(epoch, self.client, self.model, result)
                print("{},{} updated".format(epoch, self.client.rank))
                #print("{} loading weights from {}".format(self.client.rank, rank))
                self.client.load_weights(self.model, result, rank_to_read)
            #else:
              #  print("{},{} is ready - no update".format(epoch, self.client.rank))
    

    def on_train_end(self, logs={}):
        t = time.localtime()
        self.client.log("Client {} End: {}".format(self.client.rank, time.strftime('%Y-%m-%d %H:%M:%S', t)))
        self.client.done()
