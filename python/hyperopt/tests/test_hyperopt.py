from __future__ import print_function

import eqpy_hyperopt.hyperopt_runner as hr
from hyperopt import hp, base, tpe, rand
import numpy as np
import math

import threading
import eqpy
import ast

import unittest



def math_sin_func(params):
    retvals = []
    #print("len params: {}".format(len(params)))
    for p in params:
        x = p['x'][0]
        r = math.sin(x)
        retvals.append({'loss': float(r), 'status': base.STATUS_OK})
    return retvals

class TestHyperopt(unittest.TestCase):

    def test_simple_rand(self):
        space = hp.uniform('x', -2, 2)
        max_evals = 100
        trials = base.Trials()
        algo = rand.suggest #tpe.suggest
        param_batch_size = 10
        # if seed is changed then the test will fail
        rstate = np.random.RandomState(42)
        hr.fmin(math_sin_func, space, algo, max_evals,
            param_batch_size, trials, rstate=rstate)

        self.assertEqual(len(trials.results), 100)
        self.assertAlmostEqual(trials.argmin['x'], -1.5805633657891858)

    def test_simple_tpe(self):
        space = hp.uniform('x', -2, 2)
        max_evals = 100
        trials = base.Trials()
        algo = tpe.suggest #tpe.suggest
        # note that tpe won't always return more than 1
        # parameter conbimation
        max_parallel_param_count = 10
        # if seed is changed then the test will fail
        rstate = np.random.RandomState(42)
        hr.fmin(math_sin_func, space, algo, max_evals,
            max_parallel_param_count, trials, rstate=rstate)

        self.assertEqual(len(trials.results), 100)
        self.assertAlmostEqual(trials.argmin['x'], -1.5708577298673572)

    def test_eqpy(self):
        p = threading.Thread(target=hr.run)
        p.start()

        eqpy.output_q.get()
        # hyperopt args as string rep of dict:
        hp_params_dict = """{'space' : hyperopt.hp.uniform(\'x\', -2, 2),
            'algo' : hyperopt.rand.suggest, 'max_evals' : 100, 'seed' : 1234,
            'param_batch_size' : 10} """
        eqpy.input_q.put(hp_params_dict)
        # gets initial set of candidate parameters
        result = eqpy.output_q.get()
        while (True):
            # result = {'x': [1.8382913715287232]};{...}
            split_result = result.split(";")
            rs = ",".join([str(math.sin(ast.literal_eval(r)['x'][0])) for r in split_result])
            # iff algo is rand.suggest, then len(split_result) should
            # equal max_parallel_param_count
            self.assertEqual(len(split_result), 10)
            eqpy.input_q.put(rs)
            # get the next set of candidate parameters
            result = eqpy.output_q.get()
            if (result == "FINAL"):
                break

        # get final result
        self.assertEqual("{'x': -1.5477895914281512}", eqpy.output_q.get())

    def test_no_seed(self):
        """ Tests that passing no seed to eqpy_hyperopt doesn't raise
        an exception """

        p = threading.Thread(target=hr.run)
        p.start()

        eqpy.output_q.get()
        # hyperopt args as string rep of dict:
        hp_params_dict = """{'space' : hyperopt.hp.uniform(\'x\', -2, 2),
            'algo' : hyperopt.rand.suggest, 'max_evals' : 100,
            'param_batch_size' : 10} """
        eqpy.input_q.put(hp_params_dict)
        # gets initial set of candidate parameters
        result = eqpy.output_q.get()
        while (True):
            # result = {'x': [1.8382913715287232]};{...}
            split_result = result.split(";")
            rs = ",".join([str(math.sin(ast.literal_eval(r)['x'][0])) for r in split_result])
            # iff algo is rand.suggest, then len(split_result) should
            # equal max_parallel_param_count
            self.assertEqual(len(split_result), 10)
            eqpy.input_q.put(rs)
            # get the next set of candidate parameters
            result = eqpy.output_q.get()
            if (result == "FINAL"):
                break

        # get final result
        self.assertTrue(len(eqpy.output_q.get()) > 0)

if __name__ == '__main__':
    unittest.main()
