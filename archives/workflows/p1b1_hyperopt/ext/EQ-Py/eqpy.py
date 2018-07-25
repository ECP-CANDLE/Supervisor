import threading
import sys

try:
    from queue import Queue
except ImportError:
    # queue is Queue in python 2
    from Queue import Queue

input_q = Queue()
output_q = Queue()

def OUT_put(string_params):
    output_q.put(string_params)

def IN_get():
    global input_q
    # print("IN_get() ...")
    result = input_q.get()
    # print("IN_get(): " + result)
    return result

