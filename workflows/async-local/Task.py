
from __future__ import print_function

import subprocess

def task(params):
    process = subprocess.Popen(args=["./task.sh", params],
                               stdin=None,
                               stdout=None,
                               stderr=None)
    print("started: ", process.pid)
    return process
