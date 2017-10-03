
from random import randint

class State:
    seed = None
    size = None
    training = None

state = State()
    
def configure(seed, size, training):
    global state
    state.seed = seed
    state.size = size
    state.training = training

def get():
    global state
    result = []
    # Unroll range() generator into pool
    pool = []
    pool.extend(range(0, state.size-1))
    # Maximum valid index into pool
    n = state.training - 1
    for i in range(0, state.training-1):
        # print(pool)
        i = randint(0,n)
        v = pool[i]
        result.append(v)
        del pool[i]
        n = n-1
    return result

# def validation(size, training):
""" Obtain the validation set corresponding to the given training set """
