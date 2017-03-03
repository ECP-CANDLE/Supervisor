import numpy as np
import eqpy

from hyperopt import base, hp
import hyperopt

class Runner:

    def __init__(self, algo, domain, max_evals, max_parallel_param_count, trials, rstate):
        self.algo = algo
        self.domain = domain
        self.max_evals = max_evals
        self.trials = trials
        self.rstate = rstate
        self.max_parallel_param_count = max_parallel_param_count

    def run(self):
        done = 0
        while done < self.max_evals:
            n_to_enqueue = self.max_parallel_param_count
            if n_to_enqueue + done > self.max_evals:
                n_to_enqueue = self.max_evals - done

            #print("to enqueue {}".format(n_to_enqueue))
            new_ids = self.trials.new_trial_ids(n_to_enqueue)
            #print("new_ids size: {}".format(len(new_ids)))
            self.trials.refresh()

            new_trials = self.algo(new_ids, self.domain, self.trials,
                            self.rstate.randint(2 ** 31 - 1))
            if len(new_trials):
                self.trials.insert_trial_docs(new_trials)
                self.trials.refresh()
                self.evaluate()
                done += len(new_trials)
            else:
                break

        self.trials.refresh()

    def evaluate(self):
        new_trials = [t for t in self.trials._dynamic_trials if t['state'] == base.JOB_STATE_NEW]
        params = [t['misc']['vals'] for t in new_trials]
        rvals = self.domain.fn(params)
        for i in range(len(new_trials)):
            t = new_trials[i]
            t['result'] = rvals[i]
            t['state'] = base.JOB_STATE_DONE

        self.trials.refresh()

def eqpy_func(params):
    retvals = []
    # unpack and send to out
    out_params = ""
    for p in params:
        if (len(out_params) != 0):
            out_params = "{};{}".format(out_params, p)
        else:
            out_params = "{}".format(p)
    eqpy.OUT_put(out_params)

    # get result and format for hyperopt
    result = eqpy.IN_get()
    split_result = result.split(",")
    return [{'loss': float(x), 'status' : base.STATUS_OK} for x in split_result]

def run():
    """run function for eqpy based run"""
    eqpy.OUT_put("")

    # params should be formatted as a dictionary
    hp_params = eqpy.IN_get()
    hp_dict = eval(hp_params)

    trials = base.Trials()
    rstate = None
    if 'seed' in hp_dict:
        rstate = np.random.RandomState(hp_dict['seed'])

    fmin(eqpy_func, hp_dict['space'], hp_dict['algo'], hp_dict['max_evals'],
        hp_dict['max_parallel_param_count'], trials, rstate)
    eqpy.OUT_put("FINAL")
    eqpy.OUT_put(str(trials.argmin))

def fmin(fn, space, algo, max_evals, max_parallel_param_count, trials, rstate=None):
    """Minimize a function over a hyperparameter space.

    Partially copied over from the hyperopt.

    More realistically: *explore* a function over a hyperparameter space
    according to a given algorithm, allowing up to a certain number of
    function evaluations.  As points are explored, they are accumulated in
    `trials`


    Parameters
    ----------

    fn: function that takes a list of dicts of the params
        (e.g. [{x: 10, y: 20}, {x:5, y: -1.5}]) and returns results
        in the form of  {'loss': float(rval), 'status': STATUS_OK}

    space : hyperopt.pyll.Apply node
        The set of possible arguments to `fn` is the set of objects
        that could be created with non-zero probability by drawing randomly
        from this stochastic program involving involving hp_<xxx> nodes
        (see `hyperopt.hp` and `hyperopt.pyll_utils`).

    algo : search algorithm
        This object, such as `hyperopt.rand.suggest` and
        `hyperopt.tpe.suggest` provides logic for sequential search of the
        hyperparameter space.

    max_evals : int
        Allow up to this many function evaluations before returning.

    trials : None or base.Trials (or subclass)
        Storage for completed, ongoing, and scheduled evaluation points.  If
        None, then a temporary `base.Trials` instance will be created.  If
        a trials object, then that trials object will be affected by
        side-effect of this call.

    rstate : numpy.RandomState, default numpy.random"""

    if rstate is None:
        rstate = np.random.RandomState()

    # need a domain to pass to the algorithm to provide the space
    domain = base.Domain(fn, space, pass_expr_memo_ctrl=None)

    runner = Runner(algo, domain, max_evals, max_parallel_param_count,
        trials, rstate)
    runner.run()
