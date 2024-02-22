from __future__ import print_function

import json
import math
import random
import sys

"""
This script contains the hyperparameter parsing, mutation, and random draw logic for the genetic algorithm
(GA) hyperparameter optimization using deap. The params list are created, then the Hyperparemeters are 
parsed from a JSON file based on their class. Default sigma values for mutation are given but can be 
provided in the JSON file. The mutation function is defined specially for each parameter type to not corrupt
data types. The float parameter also offers a log 10 random draw and mutation functionality.

Note that there are both parameter types and element types, which are not always the same. For example,There 
could be floats in a categorical parameter.
"""


"""Setup:"""

# import logging
# logging.basicConfig()
# log = logging.getLogger("a")
# global log

# Functionality for boolean hyperparameters
def str_to_bool(s):
    if s.lower() == "true":
        return True
    else:
        return False

# Parse function to determine if something is a number
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
    
# Create parameters from JSON file (main functionality)
def create_parameters(param_file):
    with open(param_file) as json_file:
        data = json.load(json_file)

    params = []
    for item in data:
        name = item["name"]
        type = item["type"]

        if type == "int":
            lower = int(item["lower"])
            upper = int(item["upper"])
            # Allow for optional sigma
            sigma = None if "sigma" not in item else int(item["sigma"])
            params.append(IntParameter(name, lower, upper, sigma))

        elif type == "float":
            lower = float(item["lower"])
            upper = float(item["upper"])
            # Allow for optional sigma
            sigma = None if "sigma" not in item else float(item["sigma"])
            params.append(FloatParameter(name, lower, upper, sigma))

        elif type == "categorical":
            values = item["values"]
            element_type = item["element_type"]
            params.append(CategoricalParameter(name, values, element_type))

        elif type == "ordered":
            values = item["values"]
            element_type = item["element_type"]
            # Allow for optional sigma
            sigma = None if "sigma" not in item else item["sigma"]
            params.append(OrderedParameter(name, values, sigma, element_type))

        elif type == "logical":
            params.append(LogicalParameter(name))

        elif type == "constant":
            values = item["value"]
            params.append(ConstantParameter(name, values))

    return params


"""Numeric Parameters:"""

# Numeric parameter superclass (int or float)
class NumericParameter(object):

    def __init__(self, name, lower, upper, sigma=None, use_log_scale=False):
        # Check for valid bounds
        if lower >= upper:
            raise ValueError("Lower bound must be less than upper bound.")
        if lower <= 0 and use_log_scale:
            raise ValueError("Lower bound must be positive for log scale.")

        self.name = name
        self.lower = lower
        self.upper = upper
        self.use_log_scale = use_log_scale
        # Calculate default sigma if not provided
        self.sigma = sigma if sigma is not None else self.calculate_default_sigma()

    # Default sigma calculation
    def calculate_default_sigma(self):
        if self.use_log_scale:
            return self.default_log_sigma()
        else:
            return self.default_sigma()

    def default_sigma(self):
        return (self.upper - self.lower) / 10

    def default_log_sigma(self):
        log_lower = math.log10(self.lower)
        log_upper = math.log10(self.upper)
        return (log_upper - log_lower) / 10

    # General random draw function (returns float)
    def draw_float(self):
        if self.use_log_scale:
            log_lower = math.log10(self.lower)
            log_upper = math.log10(self.upper)
            x_log = random.uniform(log_lower, log_upper)
            x = 10 ** x_log
        else:
            x = random.uniform(self.lower, self.upper)
        return x
    
    # General mutation function (returns float)
    def mut_float(self, x, mu, indpb):
        if random.random() <= indpb:
            if self.use_log_scale:
                # Convert to log scale for mutation and then back
                x_log = math.log10(x)
                x_log += random.gauss(mu, self.sigma)
                x = 10 ** x_log
                x = max(self.lower, min(self.upper, x))
            else:
                x += random.gauss(mu, self.sigma)
                x = max(self.lower, min(self.upper, x))
        return x
        

# Integer parameter class
class IntParameter(NumericParameter):

    def __init__(self, name, lower, upper, sigma=None, use_log_scale=False):
        super(IntParameter, self).__init__(name, lower, upper, sigma, use_log_scale)

    # Round the float and explicitly set as int for random draw and mutation

    def randomDraw(self):
        return int(round(self.draw_float()))
    
    def mutate(self, x, mu, indpb):
        return int(round(self.mut_float(x, mu, indpb)))

    def parse(self, s):
        return int(s)


# Float parameter class
class FloatParameter(NumericParameter):

    def __init__(self, name, lower, upper, sigma=None, use_log_scale=False):
        super(FloatParameter, self).__init__(name, lower, upper, sigma, use_log_scale)

    def randomDraw(self):
        return self.draw_float()

    def mutate(self, x, mu, indpb):
        return self.mut_float(x, mu, indpb)

    def parse(self, s):
        return float(s)


"""List Parameters:"""

# List parameter superclass (categorical, ordered, or logical)
class ListParameter(object):

    def __init__(self, name, elements, element_type):
        self.name = name
        self.elements = elements

        # Determine element type within parameter type
        if element_type == "float":
            self.parse_func = float
        elif element_type == "int":
            self.parse_func = int
        elif element_type == "string":
            self.parse_func = str
        elif element_type == "logical":
            self.parse_func = str_to_bool
        else:
            raise ValueError(
                "Invalid type: {} - must be one of 'float', 'int', 'string', or 'logical'"
            )

    def randomDraw(self):
        i = random.randint(0, len(self.elements) - 1)
        return self.elements[i]
    
    def calculate_default_sigma(self):
        default_sigma = (len(self.elements)) / 10
        return default_sigma

    def parse(self, s):
        return self.parse_func(s)

# Categorical parameter class
class CategoricalParameter(ListParameter):

    def __init__(self, name, elements, element_type):
        super(CategoricalParameter, self).__init__(name, elements, element_type)

    # Mutation picks randomly from the elements while avoiding the same value
    def mutate(self, x, mu, indpb):
        if random.random() <= indpb and len(self.elements) > 1:  # Avoid mutation forever loop if only one category
            a = self.randomDraw()
            while x == a:
                a = self.randomDraw()
            x = a
        return x

# Ordered parameter class
class OrderedParameter(ListParameter):

    def __init__(self, name, elements, sigma, element_type):
        super(OrderedParameter, self).__init__(name, elements, element_type)
        self.sigma = sigma if sigma is not None else self.calculate_default_sigma()

    # Gaussian mutation is applied to the index and rounded/bounded
    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            i = self.elements.index(x)
            i_new = i + random.gauss(mu, self.sigma)
            i_new = int(round(max(0, min(len(self.elements) - 1, i_new))))
            x = self.elements[i_new]
        return x


"""Other Parameters:"""

# Constant parameter class (usually foe epochs or pathing parameters not related to the HPO process)
class ConstantParameter(object):

    def __init__(self, name, value):
        self.name = name
        self.value = value

    def randomDraw(self):
        return self.value

    def mutate(self, x, mu, indpb):
        return self.value

    def parse(self, s):
        if is_number(s):
            if "." in s or "e" in s:
                return float(s)
            return int(s)
        return s

# Logical parameter class
class LogicalParameter:

    def __init__(self, name):
        self.name = name

    def randomDraw(self):
        return random.random() < 0.5

    def mutate(self, x, mu, indpb):
        if random.random() <= indpb:
            x = not x
        return x

    def parse(self, s):
        if s.lower() == "true":
            return True
        else:
            return False


# Run main function
if __name__ == "__main__":
    create_parameters(sys.argv[1])
