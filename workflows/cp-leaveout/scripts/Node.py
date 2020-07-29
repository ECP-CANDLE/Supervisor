
# NODE PY

# The training node information as stored in the logs
# See the footer of this file for example log text that is parsed here

# import math

class Node:

    # TensorFlow is done when you see this
    training_done = "[==============================]"

    def __init__(self, id=None):
        # The ID is e.g.: "1.2.3"
        self.id = id
        # Use string length of id to deduce stage:
        self.stage = None
        # Number of training steps performed
        self.steps = 0
        self.loss = None
        # Difference wrt parent (lower is better)
        self.loss_delta = None
        self.val_loss = None
        # Validation set size
        self.val_data = None
        # Differences wrt parent (lower is better)
        self.loss_delta = None
        self.val_loss_delta = None
        # Epochs prescribed by the workflow
        self.epochs_planned = None
        # Epochs actually run (consider early stopping)
        self.epochs_actual  = 0
        self.date_start = None
        self.date_stop  = None
        # Training time in seconds
        self.time = 0
        # Did EarlyStopping stop this node?
        self.stopped_early = False
        # Did training complete for this node?
        self.complete = False
        self.verbose = False
        self.debug("START: " + str(self))

    def set_id(self, id):
        self.id = id
        self.stage = (len(self.id) - 1 ) // 2
        self.debug("SET ID: " + id)

    def parent(self):
        if self.stage == 1:
            return None
        return self.id[0:-2]

    def __str__(self):
        special = ""
        if not self.complete:
            special = " INCOMPLETE!"
        if self.stopped_early:
            special = " EARLY STOP!"
        return "Node [%s]: %s (epochs=%i/%s, loss=%s, val_loss=%s)%s" % \
            (Node.maybe_str_integer(self.stage),
             self.id,
             self.epochs_actual,
             Node.maybe_str_integer(self.epochs_planned),
             Node.maybe_str_float(self.loss,     "%0.6f"),
             Node.maybe_str_float(self.val_loss, "%0.6f"),
             special)

    def str_table(self):
        ''' Like str() but uses fixed-width fields '''
        special = ""
        if not self.complete:
            special = " INCOMPLETE!"
        if self.stopped_early:
            special = " EARLY STOP!"
        return "%-12s : %i : %2i / %2i : loss: %0.5f vl: %0.5f : %s - %s : %s" % \
            (self.id, self.stage,
             self.epochs_actual, self.epochs_planned,
             self.loss, self.val_loss,
             self.date_start, self.date_stop,
             special)

    def maybe_str_integer(i):
        if i is None:
            return "?"
        return str(i)

    def maybe_str_float(f, spec):
        if f is None:
            return "?"
        return spec % f

    def parse_epochs(self, line):
        tokens = line.split()
        self.epochs_planned = int(tokens[-1].strip())
        self.debug("epochs_planned: %i" % self.epochs_planned)

    def parse_epoch_status(self, line):
        tokens = line.split()
        assert len(tokens) == 2, "bad line: " + line
        ints = tokens[1].split("/")
        assert len(tokens) == 2
        self.epochs_actual = int(ints[0])
        self.debug("epochs_actual: " + str(self.epochs_actual))

    def stop_early(self):
        self.stopped_early = True
        self.debug("STOP EARLY")

    def parse_date_start(self, line):
        tokens = line.split()
        self.date_start = tokens[0] + " " + tokens[1]

    def parse_date_stop(self, line):
        tokens = line.split()
        self.date_stop = tokens[0] + " " + tokens[1]
        if self.epochs_actual == self.epochs_planned or \
           self.stopped_early:
            self.complete = True
            self.debug("COMPLETE")

    def parse_training_done(self, line):
        # The current epoch should already be set
        #     by parse_epoch_status()
        # First, find the location of training_done (td)
        #      (to accommodate prefixes)
        tokens = line.split()
        td = 0
        while tokens[td] != Node.training_done:
            td = td + 1
        stepii = tokens[td-1].split("/")
        self.steps += int(stepii[0])
        time_s = tokens[td+2] # e.g., "321s"
        self.time += int(time_s[0:-1])
        # Always collect losses: early stopping could happen:
        self.loss     = float(tokens[td+6])
        self.val_loss = float(tokens[td+15])

    def parse_val_data(self, fp):
        """
        fp is the file pointer to save/python.log
        If val data is not found, node.val_data will remain None
        """
        marker = "val data = "
        marker_length = len(marker)
        while True:
            line = fp.readline()
            if line == "": break
            index = line.find("val data =")
            if index == -1: continue
            tail = line[index+marker_length:]
            comma = tail.find(",")
            value_string = tail[:comma]
            self.val_data = int(value_string)

    def get_loss_delta(node):
        if node.loss_delta == None:
            raise ValueError("No loss_delta!")
        return node.loss_delta

    def get_val_loss_delta(node):
        if node.val_loss_delta == None:
            raise ValueError("No val_loss_delta!")
        return node.val_loss_delta

    def debug(self, message):
        if not self.verbose:
            return
        print("NODE: " + message)

    def total_time(self, nodes):
        parent = self.parent()
        if parent == None:
            return self.time
        return self.time + nodes[parent].total_time(nodes)

'''
EXAMPLES:

__init__()

2019-12-14 09:46:32 MODEL RUNNER DEBUG  node = 1.4.2.1

parse_epochs() ==> self.epochs_planned

2019-12-14 09:46:32 MODEL RUNNER DEBUG  epochs = 5

parse_epoch_status() (from Keras)

Epoch 29/50

parse_val_data() ==> self.val_data

2020-04-15 13:45:41 CV fold 0: train data = 5265, val data = 1400, test data = 0

stop_early()

Epoch 00004: early stopping

training_done()

16092/16092 [==============================] - 315s 20ms/step - loss: 0.0065 - mae: 0.0565 - r2: -0.6208 - val_loss: 0.0139 - val_mae: 0.0575 - val_r2: -0.3959

==> self.epochs_actual, self.val_loss, self.time, self.complete

'''
