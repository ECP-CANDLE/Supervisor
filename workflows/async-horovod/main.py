
# MAIN PY
# The main code for the search algorithm

from __future__ import print_function

import logging, os, sys, time

from utils import *

from Problem import Problem
from Task import Task

logger = logging.getLogger(__name__)

def main():
    setup_log(logging.INFO)
    parallelism, points_init, points_max, cfg, output = parse_args()
    script, launch_delay = read_cfg(cfg)
    output = setup_run(output)
    problem, optimizer = setup_optz()
    success = search(problem, optimizer, output, script, launch_delay,
                     parallelism, points_init, points_max)
    print("Workflow success!" if success else "Workflow failed!")

def setup_log(level):
    """ Note that the log level may be changed by the cfg file """
    logging.basicConfig(level=level,
                        format='%(asctime)s %(levelname)s: %(message)s',
                        datefmt='%Y/%m/%d %H:%M:%S')
    logger.debug("DEBUG")

def parse_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("parallelism",
                        help="Nodes per Keras run")
    parser.add_argument("points_init",
                        help="Number of initial sample points")
    parser.add_argument("points_max",
                        help="Number of total sample points")
    parser.add_argument("cfg_file",
                        help="The cfg file (see README)")
    parser.add_argument("output_directory",
                        help="The output directory (see README)")
    args = parser.parse_args()
    print_namespace("optimizer settings:", args)
    return (int(args.parallelism),
            int(args.points_init),
            int(args.points_max),
            args.cfg_file,
            args.output_directory)

def read_cfg(cfg):
    import json
    try:
        with open(cfg) as fp:
            J = json.load(fp)
    except:
        fail("Could not open: " + cfg)

    defaults = { "launch_delay" : 0,
                 "log_level"    : "INFO" }

    for d in defaults:
        if not d in J:
            J[d] = defaults[d]

    check(is_integer(J["launch_delay"]),
          "launch_delay must be integer if present: launch_delay=" +
          str(J["launch_delay"]))

    global logger
    level = string2level(J["log_level"])
    logger.setLevel(level)

    return J["script"], J["launch_delay"]

def setup_run(output):
    if not output[0] == "/":
        output = os.getcwd() + "/" + output
    global logger
    logger.debug("output: " + output)
    try:
        if not os.path.exists(output):
            os.makedirs(output, exist_ok=True)
        os.chdir(output)
    except Exception as e:
        fail("could not make output directory: " +
             output + "\n" + str(e))
    return output

def setup_optz():

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

def search(problem, optimizer, output, script, launch_delay,
           parallelism, points_init, points_max):
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
            global logger
            T = Task(logger, output, script,
                     parallelism, number=task_count, params=json)
            status = T.go()
            if not status:
                success = False
                break
            pids[T.process.pid] = (points[i], T)
            task_count += 1
            tasks_running += 1
            time.sleep(launch_delay)
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
        result = read_val_loss(output, task)
        optimizer.tell(point, result)

        # Create another sample point (if not exhausted or failed)
        if task_count < points_max and success:
            points = optimizer.ask(n_points=1)
        else:
            points = []
    return success

def read_val_loss(output, task):
    filename = output+"/val_loss-%04i.txt" % task.number
    try:
        with open(filename, "r") as fp:
            result = fp.read()
            result = result.strip()
    except Exception as e:
        fail("Could not open result file: " +
             filename + "\n" + str(e))
    try:
        number = float(result)
    except Exception as e:
        fail("Invalid number \"" + result + "\" in result file: " +
             filename + "\n" + str(e))

    return number 

if __name__ == '__main__':
    main()
