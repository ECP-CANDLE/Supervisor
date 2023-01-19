import os
import candle
from oned import IBenchmark

# Just because the tensorflow warnings are a bit verbose
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

# This should be set outside as a user environment variable
os.environ['CANDLE_DATA_DIR'] = os.environ['HOME'] + '/improve_data_dir'

# file_path becomes the default location of the oned_default_model.txt file
file_path = os.path.dirname(os.path.realpath(__file__))


# In the initialize_parameters() method, we will instantiate the base
# class, and finally build an argument parser to recognize your customized
# parameters in addition to the default parameters.The initialize_parameters()
# method should return a python dictionary, which will be passed to the run()
# method.
def initialize_parameters():
    i_bmk = IBenchmark(
        file_path,  # this is the path to this file needed to find default_model.txt
        'oned_default_model.txt',  # name of the default_model.txt file
        'keras',  # framework, choice is keras or pytorch
        prog='oned_baseline',  # basename of the model
        desc='IMPROVE Benchmark')

    gParameters = candle.finalize_parameters(
        i_bmk)  # returns the parameter dictionary built from
    # default_model.txt and overwritten by any
    # matching comand line parameters.

    return gParameters


import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf

def func(x, n=1):
    # "func" takes in two arguments: "x" and "n", n is set to 1.
    # The function returns a calculation using the input "x" and a default value of "n" equal to 1.
    # The calculation is a linear combination of three trigonometric functions (sine, cosine)
    # with the addition of a random normal variable scaled by the input "n".

    y = 0.02 * x + 0.5 * np.sin(1 * x + 0.1) + 0.75 * np.cos(
        0.25 * x - 0.3) + n * np.random.normal(0, 0.2, 1)
    return y[0]


def run(params):
    # fetch data
    # preprocess data
    # save preprocessed data
    # define callbacks
    # build / compile model
    # train model
    # infer using model
    # etc
    print("running third party code")

    x = params['x']
    y = func(x)

    print("returning training metrics: ", y)

    h=tf.keras.callbacks.History()
    h.history.setdefault('val_loss')

    h.history['val_loss']=y
    return h
    return {
        "val_loss": y,
    }  # metrics is used by the supervisor when running
    # HPO workflows (and possible future non HPO workflows)

    # Dumping results into file, workflow requirement
    val_scores = {
        'key': 'val_loss',
        'value': metrics['val_loss'],
        'val_loss': metrics['val_loss'],
    }

    with open(params['output_dir'] + "/scores.json", "w",
              encoding="utf-8") as f:
        json.dump(val_scores, f, ensure_ascii=False, indent=4)

    return metrics  # metrics is used by the supervisor when running
    # HPO workflows (and possible future non HPO workflows)


def main():
    params = initialize_parameters()
    scores = run(params)


if __name__ == "__main__":
    main()
