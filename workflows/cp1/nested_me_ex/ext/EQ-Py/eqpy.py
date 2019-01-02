import threading
import sys
import importlib, traceback

EQPY_ABORT = "EQPY_ABORT"

try:
    import queue as q
except ImportError:
    # queue is Queue in python 2
    import Queue as q

input_q = q.Queue()
output_q = q.Queue()

p1 = None
p2 = None
aborted = False
wait_info = None

class WaitInfo:

    def __init__(self):
        self.wait = 4

    def getWait(self):
        if self.wait < 60:
            self.wait += 1
        return self.wait

class InitializingThreadRunner(threading.Thread):

    def __init__(self, runnable):
        threading.Thread.__init__(self)
        self.runnable = runnable

    def run(self):
        # call init, but ignore error if it doesn't exist
        try:
            self.runnable.init()
        except AttributeError:
            pass

  
class ThreadRunner(threading.Thread):

    def __init__(self, runnable):
        threading.Thread.__init__(self)
        self.runnable = runnable
        self.exc = "Exited normally"

    def run(self):
        try:
            self.runnable.run()
        except BaseException:
            # tuple of type, value and traceback
            self.exc = traceback.format_exc()

def init(pkg):
    global p1, wait_info
    wait_info = WaitInfo()
    imported_pkg = importlib.import_module(pkg)
    #print(pkg);sys.stdout.flush()
    p1 = InitializingThreadRunner(imported_pkg)
    p1.start()

def run():
    global p2
    p2 = ThreadRunner(p1.runnable)
    #print(p.runnable);sys.stdout.flush()
    p2.start()

def output_q_get():
    global output_q, aborted
    wait = wait_info.getWait()
    # thread's runnable might put work on queue
    # and finish, so it would not longer be alive
    # but something remains on the queue to be pulled
    while p2.is_alive() or not output_q.empty():
        try:
            result = output_q.get(True, wait)
            break
        except q.Empty:
            pass
    else:
        # if we haven't yet set the abort flag then
        # return that, otherwise return the formated exception
        if aborted:
            result = p2.exc
        else:
            result = EQPY_ABORT
        aborted = True

    return result

import sys

def input_q_put(val):
    # print("q put {}".format(val));sys.stdout.flush()
    input_q.put(val)

def OUT_put(string_params):
    output_q.put(string_params)

def IN_get():
    # global input_q
    result = input_q.get()
    return result
