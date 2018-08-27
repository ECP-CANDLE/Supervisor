
# TASK
# This should be a user plug-in

from __future__ import print_function
import os

class Task:

    def __init__(self, logger, output, script, parallelism, number, params):
        self.logger = logger
        self.process = None
        self.fd = None
        self.output = output
        self.script = script
        self.parallelism = parallelism
        self.number = number
        self.params = params

    def go(self):
        import json, subprocess

        J = json.loads(self.params)
        learning_rate = J["learning_rate"]

        self.open_output()

        try:
            args = [ self.script, self.output, "%04i"%self.number,
                     str(self.parallelism),
                     "adam", str(learning_rate) ]
            self.logger.debug("task: " + " ".join(args))
            self.process = subprocess.Popen(args=args,
                                            stdin=None,
                                            stdout=self.fd,
                                            stderr=subprocess.STDOUT)
            print("started: ", self.process.pid)
        except Exception as e:
            import traceback
            traceback.print_exc()
            print("")
            print("error while attempting to run: " + " ".join(args))
            print(e)
            return False
        return True

    def open_output(self):
        try:
            output_file = self.output + ("/out-%04i.txt" % self.number)
            self.fd = open(output_file, "w")
        except Exception as e:
            print("")
            from utils import fail
            fail("Could not open task output file: " +
                 output_file + "\n" + str(e))

    def __del__(self):
        if self.fd is not None:
            print("closing: " + str(self.number))
            self.fd.close()
