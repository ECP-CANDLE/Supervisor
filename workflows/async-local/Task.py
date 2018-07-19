
# TASK
# This should be a user plug-in

from __future__ import print_function
import os

class Task:

    def __init__(self, parallelism, number, params):
        self.process = None
        self.fd = None
        self.parallelism = parallelism
        self.number = number
        self.params = params

    def go(self):
        import subprocess
        # script = "/home/wozniak/proj/SV/workflows/test-horovod/template-theta.sh"
        script = "/home/wozniak/proj/SV/workflows/async-local/task.sh"
        try:
            output = get_output()
            log = output + ("/%04i.txt" % self.number)
            self.fd = open(log, "w")
            self.process = subprocess.Popen(args=[script, str(self.parallelism), self.params],
                                            stdin=None,
                                            stdout=self.fd,
                                            stderr=subprocess.STDOUT)
            print("started: ", self.process.pid)
        except Exception as e:
            import traceback
            traceback.print_exc()
            return False
        return True

    def __del__(self):
        if self.fd is not None:
            print("closing: " + str(self.number))
            self.fd.close()

def get_output():
    o = os.getenv("OUTPUT")
    if o is None:
        return os.getenv("PWD")
    return o
