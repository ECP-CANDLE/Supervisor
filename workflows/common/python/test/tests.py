import unittest
import ga_utils
import random

class TestParameters(unittest.TestCase):

    def setUp(self):
        random.seed(0)
        params = ga_utils.create_parameters("./test/ga_params.json")
        self.params = {}
        for p in params:
            self.params[p.name] = p

    def testSize(self):
        self.assertEqual(6, len(self.params))

    def testInt(self):
        p = self.params['epochs']
        self.assertEqual(100, p.lower)
        self.assertEqual(500, p.upper)
        self.assertEqual(10, p.sigma)
        not_v_count = 0
        for i in range(1000):
            v = p.randomDraw()
            self.assertTrue(v >= p.lower and v <= p.upper, msg="{}".format(v))

            m = p.mutate(v, mu=0, indpb=0.0)
            self.assertEqual(v, m)

            m = p.mutate(v, mu=0, indpb=1.0)
            if m != v:
                not_v_count += 1
            self.assertTrue(m >= p.lower and m <= p.upper, msg="{}".format(m))

        self.assertTrue(not_v_count > 900, msg="not_v_count: {}".format(not_v_count))

    def testFloat(self):
        p = self.params['clipnorm']
        self.assertEqual(1e-04, p.lower)
        self.assertEqual(1e01, p.upper)
        self.assertEqual(0.2, p.sigma)
        not_v_count = 0
        for i in range(1000):
            v = p.randomDraw()
            self.assertTrue(v >= p.lower and v <= p.upper, msg="{}".format(v))

            m = p.mutate(v, mu=0, indpb=0.0)
            self.assertEqual(v, m)

            m = p.mutate(v, mu=0, indpb=1.0)
            if m != v:
                not_v_count += 1
            self.assertTrue(m >= p.lower and m <= p.upper, msg="{}".format(m))

        self.assertTrue(not_v_count > 900, msg="not_v_count: {}".format(not_v_count))

    def testCategorical(self):
        p = self.params["activation"]
        values = ["relu", 'sigmoid', 'tanh']
        self.assertEqual(values, p.categories)

        for i in range(1000):
            v = p.randomDraw()
            self.assertIn(v, values)

            m = p.mutate(v, mu=0, indpb=0.0)
            self.assertEqual(v, m)

            m = p.mutate(v, mu=0, indpb=1.0)
            self.assertNotEqual(v, m)
            self.assertIn(m, values)

    def testOrdered(self):
        p = self.params["batch_size"]
        values = [32, 64, 128, 256, 512, 1024]
        self.assertEqual(values, p.categories)
        self.assertEqual(1, p.sigma)

        for i in range(1000):
            v = p.randomDraw()
            self.assertIn(v, values)

            m = p.mutate(v, mu=0, indpb=0.0)
            self.assertEqual(v, m)

            m = p.mutate(v, mu=0, indpb=1.0)
            self.assertNotEqual(v, m)
            self.assertIn(m, values)
            v_index = values.index(v)
            m_index = values.index(m)
            self.assertTrue(abs(v_index - m_index) <= p.sigma)

    def testLogical(self):
        p = self.params["residual"]
        for i in range(1000):
            v = p.randomDraw()
            self.assertTrue(type(v) is bool)

            m = p.mutate(v, mu=0, indpb=0.0)
            self.assertEqual(v, m)

            m = p.mutate(v, mu=0, indpb=1.0)
            self.assertTrue(v is not m)

    def testConstant(self):
        p = self.params['e']
        self.assertEqual(3, p.value)

        self.assertEqual(p.value, p.randomDraw())
        self.assertEqual(p.value, p.mutate(100, mu=0, indpb=1.0))

if __name__ == '__main__':
    unittest.main()
