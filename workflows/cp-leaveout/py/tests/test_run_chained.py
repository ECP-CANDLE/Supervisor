# Run with python -m unittest tests.test_run_chained from parent directory


import unittest
import os

import run_chained

class RunChainedTests(unittest.TestCase):

    def test_root_nodes(self):
        root_node = '1'
        first_stage = 1
        n_nodes = 4
        root_nodes = run_chained.compute_parent_nodes(root_node, first_stage, n_nodes)
        self.assertEqual(['1'], root_nodes)

        first_stage = 3
        n_nodes = 4
        root_nodes = run_chained.compute_parent_nodes(root_node, first_stage, n_nodes)
        self.assertEqual(16, len(root_nodes))
        for a in range(1, 5):
            for b in range(1, 5):
                self.assertTrue('1.{}.{}'.format(a, b) in root_nodes)

    def read_lines(self, fname):
        with open(fname) as f_in:
            lines = f_in.readlines()
        return [x.strip() for x in lines]

    def test_upfs(self):

        if os.path.exists('./tests/test_out/test_upf_s1_upf.txt'):
            os.remove('./tests/test_out/test_upf_s1_upf.txt')

        args = {'upf_directory' : './tests/test_out', 'first_stage' : 1, 'stages' : 1}
        cfg = run_chained.Config(args)
        root_nodes = run_chained.compute_parent_nodes(1, 1, 4)
        run_chained.generate_upfs('test_upf', cfg, root_nodes, 4)
        vals = self.read_lines('./tests/test_out/test_upf_s1_upf.txt')
        self.assertEqual(['1.1', '1.2', '1.3', '1.4'], vals)

        if os.path.exists('./tests/test_out/test_upf_s2_upf.txt'):
            os.remove('./tests/test_out/test_upf_s2_upf.txt')
            os.remove('./tests/test_out/test_upf_s3_upf.txt')

        args = {'upf_directory' : './tests/test_out', 'first_stage' : 2, 'stages' : 2}
        cfg = run_chained.Config(args)
        root_nodes = run_chained.compute_parent_nodes(1, 2, 4)
        upfs, runs_per_stage = run_chained.generate_upfs('test_upf', cfg, root_nodes, 4)

        vals = self.read_lines(upfs[0])
        self.assertEqual(16, len(vals))
        self.assertEqual(16, runs_per_stage[0])
        for a in range(1, 5):
            for b in range(1, 5):
                self.assertTrue('1.{}.{}'.format(a, b) in vals)
        
        vals = self.read_lines(upfs[1])
        self.assertEqual(64, len(vals))
        self.assertEqual(64, runs_per_stage[1])
        for a in range(1, 5):
            for b in range(1, 5):
                for c in range(1, 5):
                    self.assertTrue('1.{}.{}.{}'.format(a, b, c) in vals)
        