from collections import OrderedDict
class Problem():
    def __init__(self):
        space = OrderedDict()
        #problem specific parameters
        space['drop'] = (0, 0.9)
        space['epochs'] = (2,3)
        space['learning_rate'] = (0.00001, 0.1)
        space['conv'] = ["50 50 50 50 50 1", "25 25 25 25 25 1", "64 32 16 32 64 1", "100 100 100 100 100 1", "32 20 16 32 10 1"]
        space['optimizer'] = ["adam", "sgd", "rmsprop", "adagrad", "adadelta"]
        space['batch_size'] = [16, 32, 64, 128, 256, 512] #, 256, 512]
        #space['p3'] = [2 , 4, 8, 16, 32, 64, 128]
        #space['p4'] = ['a', 'b', 'c']
        self.space = space
        self.params = self.space.keys()
        self.starting_point = [0.1, 16]

if __name__ == '__main__':
    instance = Problem()
    print(instance.space)
    print(instance.params)