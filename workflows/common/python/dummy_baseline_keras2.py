# DUMMY BASELINE KERAS2
# To support workflow debugging


def initialize_parameters():
    return {}  # empty dictionary


class fake_history:

    def __init__(self, x):
        self.history = {"val_loss": [x]}


def run(params):
    print("RUNNING DUMMY: " + str(params))
    import random

    # value = float(len(str(params))) + random.random()
    value = random.random()
    result = fake_history(value)
    return result
