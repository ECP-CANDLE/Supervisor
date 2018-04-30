
# MAIN PY

from __future__ import print_function

import os
import time
from skopt import Optimizer

from utils import *

from Problem import Problem
from Task import task

# Set up
problem = Problem()
starting_point = problem.starting_point

# Parameters for search workflow
init_size = 4
max_evals = 8
num_workers = 1
seed = 42

# Start the optimizer
parDict = { 'kappa' : 1.96 }
space = [problem.space[key] for key in problem.params]
opt = Optimizer(space, base_estimator='RF', acq_optimizer='sampling',
                acq_func='LCB', acq_func_kwargs={}, random_state=seed)

print("search start:")

# Create the initial sample points
points = opt.ask(n_points=init_size)

# Number of tasks submitted so far:
task_count = 0
# Number of tasks running in the background
tasks_running = 0

# Map from PID to (params, Popen object)
# Need to manage these references or Popen objects are lost
pids = {}

while True:

    jsons = create_list_of_json_strings(points, problem.params)
    for i, json in enumerate(jsons):
        # Note: this puts the task in a background process
        process = task(json)
        # print("%i -> %s" % ( process.pid, points[i]))
        pids[process.pid] = (points[i], process)
        task_count += 1
        tasks_running += 1
    print("tasks_running: ", tasks_running)
    if tasks_running == 0:
        break

    (pid, status) = os.wait()
    tasks_running -= 1

    if os.WEXITSTATUS(status):
        print("pid failed: ", pid)
        exit(1)

    (point, process) = pids[pid]
    del pids[pid]
    # print("")
    # print("completed: ", pid)
    # print("pids: ", len(pids))

    # print("point: ", str(point))
    opt.tell(point, 12)
    time.sleep(1)

    # Create another sample point (if not exhausted)
    points = opt.ask(n_points=1) if task_count < max_evals else []

print("Workflow complete!")
