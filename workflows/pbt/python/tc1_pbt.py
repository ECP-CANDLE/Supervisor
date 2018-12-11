import sys
import importlib, time
from mpi4py import MPI
import os, random, math

import ga_utils
import pbt

from keras import backend as K


class TC1PBTWorker:
    def __init__(self, rank):
        self.rank = rank

    def ready(self, pbt_client, model, epoch):
        # read every n epochs, n.b. first epoch is 0
        e = epoch + 1
        return e % 2 == 0
        # if ready:
        #     pbt_client.log("{}: ready at epoch {}".format(self.rank, epoch))
        # return ready

    def pack_data(self, pbt_client, model, metrics):
        """ Packs relevant hyperparameters and selected score metric into a dict to be
            passed to the datastore.

            :param metrics: the metrics in keras callback log
        """
        lr = float(K.get_value(model.optimizer.lr))
        data = {'lr': lr, 'score': metrics['val_loss']}
        data.update(metrics)
        #pbt_client.log("{}: putting data".format(self.rank))
        return data

    def update(self, epoch, pbt_client, model, data):
        # data: {'acc': 0.87916666666666665, 'loss': 0.38366817765765721, 'rank': 1,
        # 'score': 0.36156702836354576, 'lr': 0.0010000000474974513, 'val_acc': 0.87870370237915607,
        # 'val_loss': 0.36156702836354576}
        # current_lr = float(K.get_value(model.optimizer.lr))
        lr = data['lr']
        draw = random.random()
        if draw < .5:
            lr = lr * 0.8
        else:
            lr = lr * 1.2

        K.set_value(model.optimizer.lr, lr)
        #pbt_client.log("{},{},{},{},{}".format(self.rank, epoch, data['rank'], current_lr, lr))
        #pbt_client.log("{}: updating from rank {}, lr from {} to {}".format(self.rank, data['rank'], old_lr, lr))


def truncation_select(data, score):
    """
     :param data: list of dict containg each ranks' model data as well as
     rank itself.
     :return a dict that contains all the selected rank's model data, or an
     empty dict if no selection
    """
    # e.g. data: [{'acc': 0.87916666666666665, 'loss': 0.38366817765765721, 'rank': 1,
    # 'score': 0.36156702836354576, 'lr': 0.0010000000474974513, 'val_acc': 0.87870370237915607,
    # 'val_loss': 0.36156702836354576}, ...]
    items = sorted(data, key=lambda item: item['score'])
    size = len(items)
    quintile = int(round(size / 5.0))
    if quintile > 0 and score >= items[-quintile]['score']:
        # in bottom 20%, so select from top 20%
        if quintile == 1:
            idx = 0
        else:
            idx = random.randint(0, quintile - 1)
        #print("Returning: {}".format(items[idx]))
        return items[idx]
    else:
        #print("Returning nothing")
        return {}

def init_params(params_file, comm):
    param_factories = ga_utils.create_parameters(params_file, True)
    params = [{}]
    for i in range(comm.Get_size() - 1):
        hyper_parameter_map = {}
        for p in param_factories:
            hyper_parameter_map[p.name] = p.randomDraw()
        params.append(hyper_parameter_map)

    return params

def run_model(comm, rank, hyper_parameter_map, args):
    exp_dir = args[2]
    instance_dir = "{}/run_{}/".format(exp_dir, rank)
    if not os.path.exists(instance_dir):
        os.makedirs(instance_dir)

    model_name = args[3]

    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['save'] = '{}/output'.format(instance_dir)
    hyper_parameter_map['instance_directory'] = instance_dir
    hyper_parameter_map['model_name'] = model_name
    hyper_parameter_map['experiment_id'] = args[4]
    hyper_parameter_map['run_id'] = rank

    runner = "{}_runner".format(model_name)
    sys.argv = [runner]
    pkg = importlib.import_module(runner)
    weights_dir = "{}/weights".format(exp_dir)
    pbt_callback = pbt.PBTCallback(comm, 0, weights_dir, TC1PBTWorker(rank))

    t = time.localtime()
    pbt_callback.client.log("Client {} Start: {}".format(rank, time.strftime('%Y-%m-%d %H:%M:%S', t)))
    try:
        pkg.run(hyper_parameter_map, [pbt_callback])
    except:
        pbt_callback.client.done()
        raise


def init_dirs(outdir):
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    weights_dir = "{}/weights".format(outdir)
    if not os.path.exists(weights_dir):
        os.makedirs(weights_dir)

def main(args):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    # default to empty map indicating the param parsing failed
    params = [{} for _ in range(comm.Get_size())]
    if rank == 0:
        try:
            params = init_params(args[1], comm)
        except:
            comm.scatter(params, root=0)
            raise
        else:
            outdir = args[2]
            init_dirs(outdir)
            comm.scatter(params, root=0)
            log_file = "{}/log.txt".format(outdir)
            root = pbt.PBTMetaDataStore(comm, outdir, truncation_select, log_file)
            root.run()
    else:
        params = comm.scatter(None, root=0)
        if len(params) > 0:
            run_model(comm, rank, params, args)
        #print("{}: {}".format(rank, params))


if __name__ == '__main__':
    main(sys.argv)
