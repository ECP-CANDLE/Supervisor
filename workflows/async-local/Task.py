
# TASK
# This should be a user plug-in

from __future__ import print_function

import subprocess

def task(params):
    script = "/home/wozniak/proj/SV/workflows/test-horovod/template-theta.sh"
    process = subprocess.Popen(args=[script, params],
                               stdin=None,
                               stdout=None,
                               stderr=None)
    print("started: ", process.pid)
    return process
