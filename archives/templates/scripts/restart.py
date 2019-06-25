import os 
import datetime
import pandas as pd
import numpy as np
import json


result_file = "result.txt"
params_log = "params.json"
eval_log = "model.log"
objective_str = "objective"
eval_dir = "eval_dir"
config_json = "configuration.json"
TIME_FORMAT='%Y-%m-%d %H:%M:%S'
start = "start_time"
stop = "stop_time"
eval_key = 'id'
exp_dir = "EXPERIMENTS"
upf_space = "WORKFLOW_SETTINGS_FILE"
 

def grep(model_log):
    """
    Parse the log file to generate the start and stop times
    Arguments: 
        model_log: filepath
            The log file for the evaluation
    returns: dict
        Dictionary with start and stop times.
        
    """
    import subprocess

    global TIME_FORMAT
    global start
    global stop 
    
    output = subprocess.check_output(['grep', '-E', "RUN START|RUN STOP", model_log])
    lines = output.decode("utf-8")
    result = {}
    for line in lines.split('\n'):
        idx = line.find(' __main')
        if idx != -1:
            ts = line[0:idx]
            dt = datetime.datetime.strptime(ts, TIME_FORMAT).timestamp()
            if line.endswith('START'):
                result[start] = dt
            else:
                result[stop] = dt
    
    return result

def get_immediate_subdirectories(a_dir):
    return [name for name in os.listdir(a_dir)
        if os.path.isdir(os.path.join(a_dir, name))]


def get_successful_evaluations(all_eval):
    """
    Returns a data frame with the evaluations that run successfully only
    Arguments
        all_eval: dataframe 
            Dataframe that includes all evaluations

    Returns:
        Dataframe
    """

    global objective_str
    #For now return all evaluations that a result value. 
    u = ~all_eval[objective_str].isnull()
    return all_eval[u] 

def get_remaining_evaluations(upf_file, all_eval):
    """
    Generate a upf file with that contains all the evaluations that did not 
    complete successuflly
    
    Arguments:
        upf_file: filename 
            The orignial file that contains the parameter space
        all_eval: dataframe
            The dataframe that has attemped simulation parameters
            
    Return: str
        A str that contains information the upf info for the configuration
        that did not complete
    """
    #Read and parse the originla upf

    global eval_key

    if os.path.exists(upf_file):
        with open(upf_file, 'r') as upf:
            upf_str = upf.read() 
    else:     
        raise Exception("The upf file {} does not exist".format(upf_file))

    #parse the upf string to a list of dictionaries
    lines =  upf_str.split('\n')
    lines = [l for l in lines if l.strip() != '']
    params = []
    for configuration in lines:
        params.append(eval(configuration))
        
    total_ids = set([x[eval_key] for x in params])
    success_eval_df =  get_successful_evaluations(all_eval)
    success_ids = set(success_eval_df[eval_key].tolist())
    remaining_ids = total_ids.difference(success_ids)
    new_upf = [json.dumps(config) for config in params if config[eval_key] in remaining_ids]
    return "\n".join(new_upf)

def all_runs_log(exp_dir):
    """
    Gather information about all the runs in an experiment
    Arguments:
        exp_dir: str
            Path to the experiment directory

    Returns: Dataframe 
        Every evaluation will occupy a row 
    """

    eval_list = []
    launch_dirs = get_immediate_subdirectories(exp_dir) 
    for launch in launch_dirs: 
        run_dir  = os.path.join(exp_dir, launch, "run") 
        #print(run_dir)
        eval_dirs = get_immediate_subdirectories(run_dir)
        for evaluation in eval_dirs:
            eval_dir = os.path.join(run_dir, evaluation)
            eval_dic = single_evaluation_log(eval_dir)
            eval_list.append(pd.Series(eval_dic, index = eval_dic.keys()))

    df = pd.DataFrame(eval_list)
    return df

def single_evaluation_log(evaluation_dir):
    """
    Checks if the an evaluation is successful and generate evaluation parameters
    Arguments:
        evaluation_dir: string
            Path to the evaluation directory where a single configuration run

    returns: dict
        Dictionary with all the parameters of the evaluation and the objective value
    """

    global result_file 
    global params_log 
    global eval_log 
    global objective_str 
    global eval_dir
    global config_json 

    eval_dic = {}

    #See if evaluation completed successfully if resutls.txt contains a float    
    result_path = os.path.join(evaluation_dir, result_file)
    if not os.path.exists(result_path):
        obj_value = np.nan
    else:
        with open(result_path,mode='r') as result:
            obj_str = result.read()
        try:
            obj_value = float(obj_str)
        except Exception as e:
            obj_value =  np.nan

    eval_dic[objective_str] = obj_value

    #Read the parameters dictionary
    params_path = os.path.join(evaluation_dir, params_log)
    if os.path.exists(params_path):
        with open(params_path, 'r') as f:
            model_params = json.load(f)

    eval_dic.update(model_params)

    #Read the timing metadata
    model_log = os.path.join(evaluation_dir, eval_log)
    if os.path.exists(model_log):
        timing_dic = grep(model_log)
        eval_dic.update(timing_dic)

    return eval_dic

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description = 'Restart a UPF experiment')

    parser.add_argument('submit_args', help='The biowulf submission configuration')
    args = parser.parse_args()

    with open(args.submit_args) as json_file:  
        config_json = json.load(json_file)

    experiment = config_json[exp_dir]
    upf_file = config_json[upf_space]

    status = all_runs_log(experiment)
    new_upf = get_remaining_evaluations(upf_file, status)
    if new_upf != "":
        print(new_upf)