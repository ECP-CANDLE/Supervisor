"""SUPERVISOR MODEL RANDOM Simply returns a random number in [0,10) as
val_loss."""

import os

import tensorflow as tf
import numpy as np

import candle

# file_path becomes the default location of the oned_default_model.txt file
file_path = os.path.dirname(os.path.realpath(__file__))


class BenchmarkRandom(candle.Benchmark):
    """Our subclass implementation of a CANDLE Benchmark."""

    def set_locals(self):
        pass


# In the initialize_parameters() method, we will instantiate the base
# class, and finally build an argument parser to recognize your customized
# parameters in addition to the default parameters.The initialize_parameters()
# method should return a python dictionary, which will be passed to the run()
# method.
def initialize_parameters():
    bmk = BenchmarkRandom(
        # The path to this file needed to find default_model.txt:
        file_path,
        # The name of the default_model.txt file:
        'random_default_model.txt',
        'keras',  # framework, choice is keras or pytorch
        prog='random_baseline',  # basename of the model
        desc='Supervisor Benchmark Random')

    # Get the parameter dictionary built from
    # random_default_model.txt and modified by any
    # matching command line parameters:
    gParameters = candle.finalize_parameters(bmk)

    return gParameters


def model_implementation(params):
    """The implementation of the model w/o CANDLE conventions."""

    from random import random
    if "crash_probability" in params:
        crash_probability = float(params["crash_probability"])
        if random() < crash_probability:
            raise FakeCrashException()

    result = random() * 10
    return result


class FakeCrashException(Exception):
    """A dummy uncaught Exception to test error handling in Supervisor."""
    pass


def run(params):

    result = model_implementation(params)

    print("IMPROVE_RESULT: " + str(result))

    h = tf.keras.callbacks.History()
    h.history.setdefault('val_loss')

    y_array = np.ndarray(2)
    y_array.fill(result)
    h.history['val_loss'] = y_array
    return h
    return {
        "val_loss": result,
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
