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
    print("permute: configure(seed=%i, size=%i, training=%i)" %
          (seed, size, training))
    return "OK"


def get():
    global state
    result = []
    # Unroll range() generator into pool
    pool = []
    pool.extend(range(0, state.size))
    # Maximum valid index into pool
    n = state.training
    for i in range(0, state.training):
        # print(pool)
        i = randint(0, n + 1)
        v = pool[i]
        result.append(v)
        del pool[i]
        n = n - 1
    return result


def validation(size, training):
    """Obtain the validation set corresponding to the given training set."""
    result = []
    for i in range(0, size):
        if i not in training:
            result.append(i)
    return result


def get_tv():
    """Get training and validation."""
    global state
    t = get()
    v = validation(state.size, t)
    # return str([t, v])
    return t, v
