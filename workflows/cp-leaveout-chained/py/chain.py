import subprocess
import os
import json
import sys
import io
import argparse

import plangen

# test_chain = """
#     [
#         {
#             "script" : "./upf-test-model.sh",
#             "args" : ["cfg-sys-4.sh", "./upf-4.txt"]
#         },

#         {                                                                                                                                                            
#             "script" : "./upf-test-model.sh",                                                                                                                      "args" : ["cfg-sys-8.sh", "./upf-8.txt"]                                                                                                                 
#         }
#     ]

# """

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--plan', type=str, default='plan.json',
                        help='plan data file')
    parser.add_argument('--nodes', type=int, default=1,
                        help='number of nodes to execute each stage')
    parser.add_argument('--stages', type=int, default=1,
                        help='number of stages to run')
    parser.add_argument('--upf_dir', type=str, default=None, required=True,
        help='the output directectory for the generated upf files')
    parser.add_argument('--site', type=str, default=None, required=True,
        help='the hpc site (e.g. summit)')
    parser.add_argument('--launch_script', type=str, default=None, required=True,
        help='the script to launch the upf run for each stage')

    return parser.parse_args()

def printf(msg):
    print(msg)
    sys.stdout.flush()

# def run_chain(site):
#     chain = json.loads(test_chain)
#     job_id = None
#     for i, link in enumerate(chain):
#         script = link['script']
#         args = [site] + link['args']
#         if job_id:
#             args += ["#BSUB -w done({})".format(job_id)]
#         else:
#             args += ["## JOB 0"]
            
#         outs, errs = run_script(script, args)
#         #if len(errs) > 0:
#         printf(errs)
#         #    break
#         turbine_output, job_id = parse_run_vars(outs)
#         exp_id = os.path.basename(turbine_output)
#         printf('########### JOB {} - {} - {} ##############'.format(i,exp_id, job_id))
#         printf("Running: {} {}".format(script, ' '.join(args)))
#         printf('{}'.format(outs))
#         printf('TURBINE_OUTPUT: {}'.format(turbine_output))
#         printf('JOB_ID: {}\n'.format(job_id))


def parse_run_vars(outs):
    to_prefix = 'TURBINE_OUTPUT='
    job_id_prefix = 'JOB_ID='
    str_io = io.StringIO(outs)
    turbine_output = ''
    job_id = ''
    for line in str_io.readlines():
        line = line.strip()
        if line.startswith(to_prefix):
            turbine_output = line[len(to_prefix) : ]
        elif line.startswith(job_id_prefix):
            job_id = line[len(job_id_prefix) : ]
            
    return (turbine_output, job_id)


def run_script(script, args):
    # bname = os.path.splitext(os.path.basename(script))[0]
    # err = open('./{}_err.txt'.format(bname), 'w')
    # out = open('./{}_out.txt'.format(bname), 'w')
    cmd = [script] + args
    # print('{} subprocess start: {}'.format(rank, str(datetime.datetime.now())))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    outs, errs = p.communicate()
    # ret = err.tell() == 0
    # err.close()
    # out.close()
    # return ret
    return (outs.decode('utf-8'), errs.decode('utf-8'))

def run_upfs(upfs, launch_script, site, plan_file):
    for i, upf in enumerate(upfs):
        # UPFS are in stage order
        job_id = None
        args = [site, '-a', 'cfg-sys-s{}.sh'.format(i), plan_file, upf, str(i + 1)]
        if job_id:
            args += ["#BSUB -w done({})".format(job_id)]
        else:
            args += ["## JOB 0"]
            
        outs, errs = run_script(launch_script, args)
        #if len(errs) > 0:
        printf(errs)
        #    break
        turbine_output, job_id = parse_run_vars(outs)
        exp_id = os.path.basename(turbine_output)
        printf('########### JOB {} - {} - {} ##############'.format(i,exp_id, job_id))
        printf("Running: {} {}".format(launch_script, ' '.join(args)))
        printf('{}'.format(outs))
        printf('TURBINE_OUTPUT: {}'.format(turbine_output))
        printf('JOB_ID: {}\n'.format(job_id))

def get_plan_info(plan_file):
    plan_dict = plangen.load_plan(plan_file)
    # key of first entry is the root node
    iter_pd = iter(plan_dict)
    root_node = next(iter_pd)
    total_stages = -1
    total_nodes = -1
    for k in iter_pd:
        # has skipped the root node, so we can get 
        # the second element in val
        vals = (k.split("."))
        n_vals = len(vals)
        total_stages = max(total_stages, n_vals)
        total_nodes = max(total_nodes, int(vals[1]))
    
    return (root_node, total_stages, total_nodes)

def generate_upfs(prefix, upf_dir, root_node, n_stages, n_nodes):
    parents = [root_node]
    upf_prefix = '{}/{}_'.format(upf_dir, prefix)
    upfs = []
    for s in range(1, n_stages):
        upf_path = '{}s{}_upf.txt'.format(upf_prefix, s)
        parents = generate_stage(parents, n_nodes, upf_path)
        upfs.append(upf_path)

    return upfs

def generate_stage(parents, n_nodes, f_path):
    children = []
    with open(f_path, 'w') as f_out:
        for p in parents:
            for n in range(1, n_nodes + 1):
                child = '{}.{}'.format(p, n)
                f_out.write('{}\n'.format(child))
                # TODO write children
                children.append(child)
    # print('Stage {}: {}'.format(stage, ' '.join(children)))
    return children
   

def run(args):
    plan_file = args.plan
    n_nodes = args.nodes
    n_stages = args.stages

    root_node, total_stages, total_nodes = get_plan_info(plan_file)
    if n_nodes == -1 or n_nodes > total_nodes:
        n_nodes = total_nodes
    if n_stages == -1 or n_stages > total_stages:
        n_stages = total_stages

    prefix = os.path.splitext(os.path.basename(plan_file))[0]
    upfs = generate_upfs(prefix, args.upf_dir, root_node, n_stages, n_nodes)
    run_upfs(upfs, args.launch_script, args.site)

if __name__ == "__main__":
    args = parse_arguments()
    run(args)
