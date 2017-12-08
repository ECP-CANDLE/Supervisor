from __future__ import print_function
import random, json, sys

class ConstantParameter(object):

    def __init__(self, name, value):
        self.name = name
        self.value = value

    def randomDraw(self):
        return self.value

    def mutate(self, x, mu, indpb):
        return self.value

class NumericParameter(object):

    def __init__(self, name, lower, upper, sigma):
        self.name = name
        self.lower = lower
        self.upper = upper
        self.sigma = sigma

    def randomDraw(self):
        x = self.uni_rand_func(self.lower, self.upper)
        return x

class IntParameter(NumericParameter):

    def __init__(self, name, lower, upper, sigma):
        super(IntParameter, self).__init__(name, lower, upper, sigma)
        self.uni_rand_func = random.randint


    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            x += random.gauss(mu, self.sigma)
            x = int(max(self.lower, min(self.upper, round(x))))
        return x

class FloatParameter(NumericParameter):

    def __init__(self, name, lower, upper, sigma):
        super(FloatParameter, self).__init__(name, lower, upper, sigma)
        self.uni_rand_func = random.uniform

    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            x += random.gauss(mu, self.sigma)
            x = max(self.lower, min(self.upper, x))
        return x

#import logging
#logging.basicConfig()
#log = logging.getLogger("a")

class CategoricalParameter:

    def __init__(self, name, categories):
        self.name = name
        self.categories = categories

    def randomDraw(self):
        i = random.randint(0, len(self.categories) - 1)
        return self.categories[i]

    def mutate(self, x, mu, indpb):
        global log
        if random.random() <= indpb:
            a = self.randomDraw()
            while x == a:
                a = self.randomDraw()
            x = a
        return x

class OrderedParameter:

    def __init__(self, name, categories, sigma):
        self.name = name
        self.categories = categories
        self.sigma = sigma

    def randomDraw(self):
        i = random.randint(0, len(self.categories) - 1)
        return self.categories[i]

    def drawIndex(self, i):
        n = random.randint(1, self.sigma)
        n = i + (n if random.random() < 0.5 else -n)
        n = max(0, min(len(self.categories) - 1, n))
        return n

    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            i = self.categories.index(x)
            n = self.drawIndex(i)
            while n == i:
                n = self.drawIndex(i)

            x = self.categories[n]
        return x

class LogicalParameter:

    def __init__(self, name):
        self.name = name

    def randomDraw(self):
        return random.random() < 0.5

    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            x = not x
        return x

def create_parameters(param_file):
    with open(param_file) as json_file:
        data = json.load(json_file)

    params = []
    for item in data:
        name = item['name']
        t = item['type']
        if t == 'int' or t == 'float':
            lower = item['lower']
            upper = item['upper']
            sigma = item['sigma']

            if t == 'int':
                params.append(IntParameter(name, int(lower), int(upper),
                                       int(sigma)))
            else:
                params.append(FloatParameter(name, float(lower), float(upper),
                                       float(sigma)))

        elif t == 'categorical':
            vs = item['values']
            params.append(CategoricalParameter(name, vs))

        elif t == 'logical':
            params.append(LogicalParameter(name))

        elif t == "ordered":
            vs = item['values']
            sigma = item['sigma']
            params.append(OrderedParameter(name, vs, sigma))
        elif t == 'constant':
            vs = item['value']
            params.append(ConstantParameter(name, vs))

    return params

if __name__ == '__main__':
    create_parameters(sys.argv[1])
