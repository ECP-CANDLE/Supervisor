from __future__ import print_function
import unittest
import tc1_pbt
import pbt_utils
import numpy as np
import keras

from keras.optimizers import Adam
from keras import backend as K

class TestPBT(unittest.TestCase):

    def testTruncate(self):
        data = []
        for i in range(0, 11):
            data.append({'score': 11 - i, 'rank': i})

        #print(data)
        for i in range(0, 10):
            result = tc1_pbt.truncation_select(data, i)
            self.assertEqual(0, len(result))

        for i in range(10, 12):
            result = tc1_pbt.truncation_select(data,  i)
            self.assertTrue(len(result) > 0)
            score = result['score']
            rank = result['rank']
            self.assertTrue(rank == 9 or rank == 10)
            self.assertTrue(score < 3)

class TestIO(unittest.TestCase):

    def create_model(self, lr):
        X, y = np.random.rand(100, 50), np.random.randint(2, size=100)
        x = keras.layers.Input((50,))
        out = keras.layers.Dense(1, activation='sigmoid')(x)
        model = keras.models.Model(x, out)
        optimizer = Adam(lr=lr)
        model.compile(optimizer=optimizer, loss='binary_crossentropy')
        model.fit(X, y, epochs=5)
        return model

    def testIO(self):
        model = self.create_model(.0001)
        lr = float(K.get_value(model.optimizer.lr))
        self.assertAlmostEqual(0.0001, lr)
        weights = model.get_weights()
        pbt_utils.save_state(model, "./test/test_out/", 0)

        # new model
        model = self.create_model(0.01)
        self.assertFalse(np.array_equal(weights[0], model.get_weights()[0]))
        lr = float(K.get_value(model.optimizer.lr))
        self.assertAlmostEqual(0.01, lr)
        pbt_utils.load_state(model, "./test/test_out/", 0)
        lr = float(K.get_value(model.optimizer.lr))
        self.assertAlmostEqual(0.0001, lr)
        self.assertEqual(len(weights), len(model.get_weights()))
        self.assertTrue(np.array_equal(weights[0], model.get_weights()[0]))


if __name__ == '__main__':
    unittest.main()
