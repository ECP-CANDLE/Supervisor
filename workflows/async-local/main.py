
# MAIN PY
# The main code for the search algorithm

from __future__ import print_function

import logging, os, sys, time

from utils import *

from Problem import Problem
from Task import Task

logger = logging.getLogger(__name__)

def main():
    setup_log()
    parallelism, points_init, points_max = parse_args()
    problem, optimizer = setup()
    success = search(problem, optimizer,
                     parallelism, points_init, points_max)
    print("Workflow success!" if success else "Workflow failed!")

def setup_log():
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s %(levelname)s: %(message)s',
                        datefmt='%Y/%m/%d %H:%M:%S')

def parse_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("parallelism")
    parser.add_argument("points_init")
    parser.add_argument("points_max")
    args = parser.parse_args()
    print_namespace("optimizer settings:", args)
    return (int(args.parallelism),
            int(args.points_init),
            int(args.points_max))

def setup():

    logger.debug("setup() START")
    from skopt import Optimizer

    # Set up
    problem = Problem()
    starting_point = problem.starting_point
    seed = 42

    # Start the optimizer
    parDict = { 'kappa' : 1.96 }
    space = [problem.space[key] for key in problem.params]
    optimizer = Optimizer(space, base_estimator='RF', acq_optimizer='sampling',
                    acq_func='LCB', acq_func_kwargs={}, random_state=seed)
    logger.debug("setup() STOP")
    return (problem, optimizer)

def search(problem, optimizer, parallelism, points_init, points_max):
    print("search start:")

    # Create the initial sample points
    points = optimizer.ask(n_points=points_init)

    # Number of tasks submitted so far:
    task_count = 0
    # Number of tasks running in the background
    tasks_running = 0

    # Map from PID to (params, Task object)
    # Need to hold these references or Popen objects are garbage-collected
    pids = {}

    # Once we find a failure, we stop producing new tasks
    success = True

    while True:

        jsons = create_list_of_json_strings(points, problem.params)
        for i, json in enumerate(jsons):
            # Note: this puts the task in a background process
            T = Task(parallelism, number=task_count, params=json)
            status = T.go()
            if not status:
                success = False
                break
            pids[T.process.pid] = (points[i], T)
            task_count += 1
            tasks_running += 1
        print("tasks_running: ", tasks_running)
        if tasks_running == 0:
            break

        # Wait for exactly one task to complete, get its PID
        (pid, status) = os.wait()
        tasks_running -= 1
        if os.WEXITSTATUS(status):
            print("pid failed: ", pid)
            success = False

        # Look up the task and delete it from the dictionary
        (point, task) = pids[pid]
        del pids[pid]

        # Pass the result back to the optimizer
        optimizer.tell(point, 12)
        # time.sleep(1)

        # Create another sample point (if not exhausted or failed)
        if task_count < points_max and success:
            points = optimizer.ask(n_points=1)
        else:
            points = []
    return success

if __name__ == '__main__':
    main()
