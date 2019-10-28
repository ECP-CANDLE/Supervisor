import subprocess
import os
import json
import sys
import io
import argparse

import plangen

class Config:
    
    REQS = ['site', 'plan', 'submit_script', 'upf_directory', 'stages', 'stage_cfg_script']
    STAGE_CFG_KEYS = ['stage', 'PROCS', 'TURBINE_LAUNCH_ARGS', 'TURBINE_DIRECTIVE_ARGS',
                'WALLTIME', 'IGNORE_ERRORS', 'SH_TIMEOUT', 'BENCHMARK_TIMEOUT',
                'PPN']
    INT_KEYS = ['PROCS', 'PPN', 'BENCHMARK_TIMEOUT', 'SH_TIMEOUT', 'IGNORE_ERRORS']
    
    def __init__(self, cfg):
        self.cfg = cfg
        self.stage_cfgs = {}

    def validate(self):
        for r in Config.REQS:
            if not r in self.cfg:
                return (False, "Required property '{}' is missing".format(r))
        
        self.cfg['stages'] = int(self.cfg['stages'])

        if 'stage_cfgs' in self.cfg:
            for stage_cfg in self.cfg['stage_cfgs']:
                if not 'stage' in stage_cfg:
                    return (False, "A stage_cfg map is missing required 'stage' property")
                for k in stage_cfg:
                    if k not in Config.STAGE_CFG_KEYS:
                        return (False, "Unknow stage configuration property {}".format(k))
                
                stage = int(stage_cfg['stage'])
                # delete it as its not a proper env var
                del stage_cfg['stage']
                self.stage_cfgs[stage] = stage_cfg


        return (True,)

    def get_stage_environment(self, stage):
        env = os.environ.copy()
        if stage in self.stage_cfgs:
            env.update(self.stage_cfgs[stage])
        return env

    def _vars_to_string(self, scfg):
        for k in Config.INT_KEYS:
            if k in scfg:
                scfg[k] = str(scfg[k])

    def update_stage_cfgs(self, runs_per_stage):
        for i, runs in enumerate(runs_per_stage):
            stage = i + 1
            if stage in self.stage_cfgs:
                scfg = self.stage_cfgs[stage]
                if "PROCS" not in scfg:
                    scfg['PROCS'] = str(runs + 1)
                if "PPN" not in scfg:
                    scfg['PPN'] = str(1)
            
                # update any numeric vals to str values as required for env vars
                self._vars_to_string(scfg)
            else:
                self.stage_cfgs[stage] = {'PROCS' : str(runs + 1), 'PPN' : str(1)}
 
    @property
    def site(self):
        return self.cfg['site']

    @property
    def plan(self):
        return self.cfg['plan']

    @property
    def submit_script(self):
        return self.cfg['submit_script']

    @property
    def upf_directory(self):
        return self.cfg['upf_directory']

    @property
    def stages(self):
        return self.cfg['stages']
    
    @stages.setter
    def stages(self, value):
        self.cfg['stages'] = value

    @property
    def stage_cfg_script(self):
        return self.cfg['stage_cfg_script']

    
def parse_arguments():
    parser = argparse.ArgumentParser()
    # parser.add_argument('--plan', type=str, default='plan.json',
    #                     help='plan data file')
    parser.add_argument('--stages', type=int, default=0,
                        help='number of stages to run (overrides configuration file if non-0)')
    parser.add_argument('--config', type=str, default=None, required=True,
         help='the configuration file in json format')
    parser.add_argument('--dry_run', action='store_true',
         help="Runs the workflow with actual job submission, displaying each job's configuration")

    # parser.add_argument('--upf_dir', type=str, default=None, required=True,
    #     help='the output directory for the generated upf files')
    # parser.add_argument('--site', type=str, default=None, required=True,
    #     help='the hpc site (e.g. summit)')
    # parser.add_argument('--submit_script', type=str, default=None, required=True,
    #     help='the script to submit the job for each stage')

    return parser.parse_args()

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


def run_script(cfg, args, stage):
    cmd = [cfg.submit_script] + args
    env = cfg.get_stage_environment(stage)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
    # stderr is redirected to stdout
    outs, _ = p.communicate()
    return outs.decode('utf-8')

def run_dry_run(upfs, cfg):

    for i, upf in enumerate(upfs):
        # UPFS are in stage order
        stage = i + 1
        args = [cfg.site, '-a', cfg.stage_cfg_script, cfg.plan, upf, str(i + 1)]
        if i > 0:
            args += ['<parent_turbine_output>', '#BSUB -w done(<parent_job_id>)']
        else:
            args += ['job0', '## JOB 0']

        print('\n########### DRY RUN JOB {}  ##############'.format(stage))
        print("Running: {} {}".format(cfg.submit_script, ' '.join(args)))
        env = cfg.get_stage_environment(stage)
        if 'TURBINE_DIRECTIVE_ARGS' in env:
            env['TURBINE_DIRECTIVE_ARGS'] = '{}\\n{}'.format(args[7], env['TURBINE_DIRECTIVE_ARGS'])
        else:
            env['TURBINE_DIRECTIVE_ARGS'] = args[7]
        p = subprocess.Popen(['bash', "-c",  "source {}".format(cfg.stage_cfg_script)], stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, env=env)
        # stderr is redirected to stdout
        outs, _ = p.communicate()
        print(outs.decode('utf-8'))

def run_upfs(upfs, cfg):
    job_id = None
    turbine_output = None
    for i, upf in enumerate(upfs):
        # UPFS are in stage order
        stage = i + 1
        args = [cfg.site, '-a', cfg.stage_cfg_script, cfg.plan, upf, str(stage)]
        if job_id:
            args += [turbine_output, '#BSUB -w done({})'.format(job_id)]
        else:
            args += ['job0', '## JOB 0']

        outs = run_script(cfg, args, stage)
        turbine_output, job_id = parse_run_vars(outs)
        exp_id = os.path.basename(turbine_output)
        print('\n########### JOB {} - {} - {} ##############'.format(stage, exp_id, job_id))
        print("Running: {} {}".format(cfg.submit_script, ' '.join(args)))
        print(outs)
        print('TURBINE_OUTPUT: {}'.format(turbine_output))
        print('JOB_ID: {}\n'.format(job_id))
        if not job_id:
            print("JOB_ID NOT FOUND - ABORTING RUNS")
            break

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
    counts = []
    for s in range(1, n_stages + 1):
        upf_path = '{}s{}_upf.txt'.format(upf_prefix, s)
        parents = generate_stage(parents, n_nodes, upf_path)
        upfs.append(upf_path)
        counts.append(len(parents))

    return (upfs, counts)

def generate_stage(parents, n_nodes, f_path):
    children = []
    with open(f_path, 'w') as f_out:
        for p in parents:
            for n in range(1, n_nodes + 1):
                child = '{}.{}'.format(p, n)
                f_out.write('{}\n'.format(child))
                children.append(child)
    # print('Stage {}: {}'.format(stage, ' '.join(children)))
    return children
   
def parse_config(args):
    cfg = None
    with open(args.config, 'r') as fin:
        cfg = Config(json.load(fin))
    result = cfg.validate()
    if not result[0]:
        print("Configuration ERROR in {}: {}".format(args.config, result[1]))
        sys.exit()

    if args.stages != 0:
        cfg.stages = args.stages
    
    return cfg
    
def run(args):
    cfg = parse_config(args)
    root_node, total_stages, n_nodes = get_plan_info(cfg.plan)
    if cfg.stages == -1 or cfg.stages >= total_stages:
        cfg.stages = total_stages

    prefix = os.path.splitext(os.path.basename(cfg.plan))[0]
    upfs, runs_per_stage = generate_upfs(prefix, cfg.upf_directory, root_node, cfg.stages, n_nodes)
    cfg.update_stage_cfgs(runs_per_stage)

    print("\nTotal Jobs: {}\nTotal Stages: {}\nNodes: {}".format(cfg.stages, cfg.stages, n_nodes))
    print("Site: {}\nPlan: {}\nSubmit Script: {}\nStage Configuration Script:{}\nUPF directory: {}".format(cfg.site, cfg.plan,
        cfg.submit_script,  cfg.stage_cfg_script, cfg.upf_directory))
    for i, c in enumerate(runs_per_stage):
        stage = i + 1
        scfg = cfg.stage_cfgs[stage]
        print("\tStage: {}, UPF: {}, Model Runs: {}, PROCS: {}, PPN: {}".format(stage, 
                    os.path.basename(upfs[i]), c, scfg['PROCS'], scfg['PPN']))  


    # TODO Add Dry Run -- for each upf source the cfg-sys as a POpen
    if args.dry_run:
        run_dry_run(upfs, cfg)
    else:
        run_upfs(upfs, cfg)

if __name__ == "__main__":
    args = parse_arguments()
    run(args)
