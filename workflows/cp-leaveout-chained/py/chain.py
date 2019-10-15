import subprocess
import os
import json
import sys
import io

test_chain = """
    [
        {
            "script" : "./upf-test-model.sh",
            "args" : ["./upf_test.txt"]
        }
    ]
"""

def run_chain(site):
    chain = json.loads(test_chain)
    for link in chain:
        script = link['script']
        args = [site] + link['args']
        outs, errs = run_script(script, args)
        if len(errs) > 0:
            print(errs)
            break
        turbine_output, exp_id, job_id = parse_run_vars(outs)
        print(turbine_output)
        print(exp_id)
        print(job_id)


def parse_run_vars(outs):
    lines = outs.split('\n')
    last = -1
    if len(lines[-1]) == 0:
        last = -2
    exp_id = lines[last - 1]
    turbine_output = lines[last]

    with open('{}/jobid.txt'.format(turbine_output), 'r') as f_in:
        job_id = f_in.readline().trim()
        
    return (turbine_output, exp_id, job_id)


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