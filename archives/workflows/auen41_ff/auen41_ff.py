import json
import time

import matplotlib as mpl
import numpy as np
import pandas as pd
from keras.layers import Dense, Dropout, Input
from keras.models import Model

mpl.use('Agg')
import matplotlib.pyplot as plt

EPOCH = 10
BATCH = 50

P = 60025  # 245 x 245
N1 = 2000
NE = 600  # encoded dim
F_MAX = 33.3
DR = 0.2


class AutoEncoder():

    def __init__(self, trainFileName, testFileName, metaDataDict):
        self.train = None
        self.test = None
        self.x_train = None
        self.x_test = None
        self.diffs = None
        self.initTime = None
        self.trainTime = None
        self.testTime = None
        self.ae = None
        self.resultJson = None
        self.resultDict = {}

        self.metaDataDict = metaDataDict
        self.train = self.readFile(trainFileName)
        self.test = self.readFile(testFileName)
        self.normalizeData()
        self.createEncoder()
        self.trainEncoder()
        self.testEncoder()
        self.collectResult()

    def readFile(self, fileName):
        df = (pd.read_csv(fileName).values).astype('float32')
        return df

    def normalizeData(self):
        self.x_train = self.train[:, 0:P] / F_MAX
        self.x_test = self.test[:, 0:P] / F_MAX

    def createEncoder(self):
        start = time.time()
        input_vector = Input(shape=(P,))
        x = Dense(N1, activation='sigmoid')(input_vector)
        x = Dense(NE, activation='sigmoid')(x)
        encoded = x
        x = Dense(N1, activation='sigmoid')(encoded)
        x = Dense(P, activation='sigmoid')(x)
        decoded = x
        self.ae = Model(input_vector, decoded)
        end = time.time()
        encoded_input = Input(shape=(NE,))
        self.encoder = Model(input_vector, encoded)
        self.decoder = Model(
            encoded_input,
            self.ae.layers[-1](self.ae.layers[-2](encoded_input)))
        self.ae.compile(optimizer='rmsprop', loss='mean_squared_error')
        self.initTime = end - start
        print "autoencoder summary"
        self.ae.summary()

    def trainEncoder(self):
        start = time.time()
        self.ae.fit(self.x_train,
                    self.x_train,
                    batch_size=BATCH,
                    nb_epoch=EPOCH,
                    validation_data=[self.x_test, self.x_test])
        end = time.time()
        self.trainTime = end - start

    def testEncoder(self):
        start = time.time()
        encoded_image = self.encoder.predict(self.x_test)
        decoded_image = self.decoder.predict(encoded_image)
        diff = decoded_image - self.x_test
        end = time.time()
        self.testTime = end - start
        self.diffs = diff.ravel()

    def collectResult(self):
        self.resultDict['initTime'] = self.initTime
        self.resultDict['trainTime'] = self.trainTime
        self.resultDict['testTime'] = self.testTime
        self.resultDict['epocs'] = EPOCH
        self.resultDict['timeStamp'] = time.time()
        for key in self.metaDataDict.keys():
            self.resultDict[key] = self.metaDataDict[key]
        self.resultJson = json.dumps(self.resultDict)

    def printResults(self):
        print self.resultJson

    def plotResults(self):
        plt.hist(self.diffs, bins='auto')
        plt.title("Histogram of Errors with 'auto' bins")
        plt.savefig('histogram.png')


def saveJsonResult(jsonResult, jsonFilename):
    f = open(jsonFilename, 'w')
    f.write('[\n')
    for i, val in enumerate(jsonResult):
        if i < len(jsonResult) - 1:
            f.write('\t' + val + ',\n')
        else:
            f.write('\t' + val + '\n')
    f.write(']\n')
    f.close()


def go(dir):
    # runs = 5
    jsonResult = []
    metaDataDict = {}
    metaDataDict['target'] = 'knl'
    metaDataDict['method'] = 'dl'
    metaDataDict['lib'] = 'intel-tf'
    metaDataDict['benchmark-name'] = 'benchmark1'
    metaDataDict['type'] = 'autoencoder'
    # for i in range(runs):
    autoencode = AutoEncoder(dir + '/breast.train.csv',
                             dir + '/breast.test.csv', metaDataDict)
    jsonResult.append(autoencode.resultJson)
    print jsonResult
    saveJsonResult(jsonResult, 'jsonResults.json')
    return repr(jsonResult)
    # return "OK"


if __name__ == '__main__':
    go('.')
