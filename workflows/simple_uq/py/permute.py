
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
    return 42
