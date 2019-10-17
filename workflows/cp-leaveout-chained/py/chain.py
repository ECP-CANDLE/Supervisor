import subprocess
import os
import json
import sys
import io

test_chain = """
    [
        {
            "script" : "./upf-test-model.sh",
            "args" : ["cfg-sys-4.sh", "./upf-4.txt"]
        },

        {                                                                                                                                                            
            "script" : "./upf-test-model.sh",                                                                                                                      "args" : ["cfg-sys-8.sh", "./upf-8.txt"]                                                                                                                 
        }
    ]

"""

def printf(msg):
    print(msg)
    sys.stdout.flush()

def run_chain(site):
    chain = json.loads(test_chain)
    job_id = None
    for i, link in enumerate(chain):
        script = link['script']
        args = [site] + link['args']
        if job_id:
            args += ["#BSUB -w done({})".format(job_id)]
        else:
            args += ["## FIRST JOB"]
            
        outs, errs = run_script(script, args)
        #if len(errs) > 0:
        printf(errs)
        #    break
        turbine_output, job_id = parse_run_vars(outs)
        exp_id = os.path.basename(turbine_output)
        printf('########### JOB {} - {} - {} ##############'.format(i,exp_id, job_id))
        printf("Running: {} {}".format(script, ' '.join(args)))
        printf('{}'.format(outs))
        printf('TURBINE_OUTPUT: {}'.format(turbine_output))
        printf('JOB_ID: {}\n'.format(job_id))


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


# def prep_script(script, new_script):
#     with open(new_script, 'w') as f_out:
#         with open(script, 'r') as f_in:
#             for line in f_in.readlines():
#                 f_out.write("{}\n".format(line))
#         f_out.write("echo $TURBINE_OUTPUT\n")
#         f_out.write("echo $EXP_ID\n")
#     os.chmod(new_script, stat.S_IRWXU)
    

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

if __name__ == "__main__":
    site = sys.argv[1]
    run_chain(site)
