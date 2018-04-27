
from utils import *
from Problem import Problem
from skopt import Optimizer

problem = Problem()

spaceDict = problem.space
params = problem.params
starting_point = problem.starting_point

init_size = 4
max_evals = 8
num_workers = 1
seed = 42

parDict = {}
resultsList = []
parDict['kappa'] = 1.96
init_x = []

space = [spaceDict[key] for key in params]

opt = Optimizer(space, base_estimator='RF', acq_optimizer='sampling',
                acq_func='LCB', acq_func_kwargs=parDict, random_state=seed)

eval_counter = 0
askedDict = {}
print("Master starting with {} init_size, {} max_evals, {} num_workers".format(init_size,max_evals,num_workers))
x = opt.ask(n_points=init_size)

print(x)

json = create_list_of_json_strings(x, problem.params)

x = opt.ask()

json = create_list_of_json_strings(x, problem.params)
print(json)
