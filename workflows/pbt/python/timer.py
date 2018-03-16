import time

class Timer:

    def start(self):
        self.t = time.time()

    def end(self, msg):
        duration = time.time() - self.t
        print("{} - {}s".format(msg, duration))
