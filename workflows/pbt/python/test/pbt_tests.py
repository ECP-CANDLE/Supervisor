import unittest

import tc1_pbt

class TestPBT(unittest.TestCase):

    def testTruncate(self):
        data = {}
        for i in range(0, 11):
            data[i] = {'score': 11 - i}

        print(data)
        for i in range(0, 10):
            result = tc1_pbt.truncatation_select(data, i)
            self.assertEqual(0, len(result))

        for i in range(10, 12):
            result = tc1_pbt.truncatation_select(data,  i)
            self.assertTrue(len(result) > 0)
            rank = result[0]
            score = result[1]['score']
            self.assertTrue(rank == 9 or rank == 10)
            self.assertTrue(score < 3)
