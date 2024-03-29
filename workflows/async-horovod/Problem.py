# PROBLEM
# The bounding box for the optimization problem
# This should be a user plug-in

from collections import OrderedDict


class Problem:

    def __init__(self):
        space = OrderedDict()
        # problem specific parameters
        # space['drop'] = (0, 0.9)
        # space['batch_size'] = [16, 32, 64, 128, 256, 512]
        # space['p3'] = [2 , 4, 8, 16, 32, 64, 128]
        # space['p4'] = ['a', 'b', 'c']
        # space["learning_rate"] = (0,0.009) # Make discrete values
        space["learning_rate"] = [
            0.001,
            0.002,
            0.003,
            0.004,
            0.005,
            0.006,
            0.007,
            0.008,
            0.009,
        ]
        # Use 5 epochs
        # Add Horovod PARALLELISM [ 64, 128 , 256, 512 ]
        #                           ?   1.5h    ?   ?
        # Add batch size
        self.space = space
        self.params = self.space.keys()
        self.starting_point = [0.1, 16]


# if __name__ == '__main__':
#     instance = Problem()
#     print(instance.space)
#     print(instance.params)
