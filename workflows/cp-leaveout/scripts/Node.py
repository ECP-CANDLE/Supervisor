# NODE PY

# The training node information as stored in the logs
# See the footer of this file for example log text that is parsed here
# This class must remain simple enough to pickle
#      thus it cannot contain its own logger (Python 3.6 issue 30520)

# import math


class Node:

    # TensorFlow is done when you see this
    training_done = "[==============================]"

    def __init__(self, id=None, logger=None):
        # The ID is e.g.: "1.2.3"
        self.id = id
        # Use string length of id to deduce stage:
        self.stage = None
        # Number of training steps performed
        self.steps = 0
        # Various error metrics:
        self.loss = None
        self.val_loss = None
        self.mse = None
        self.mae = None
        self.r2 = None
        self.corr = None
        # The first learning rate:
        self.lr_first = None
        # The final learning rate:
        self.lr_final = None
        # Differences wrt parent (lower is better)
        self.loss_delta = None
        self.val_loss_delta = None
        # Validation set size
        self.val_data = None
        # Epochs prescribed by the workflow
        self.epochs_planned = None
        # Epochs actually run (consider early stopping)
        self.epochs_actual = 0
        # Epochs cumulative: include parents' epochs (CP weight-sharing)
        self.epochs_cumul = None
        self.date_start = None
        self.date_stop = None
        # Time to build dataframe
        self.build_df = None
        # Time to load initial weights
        self.load_initial = None
        # Training time in seconds
        self.time = 0
        # Training run restarts- each log file makes a new segment
        self.segment = 0
        # Time for given segment from "Current time"
        self.segments = {}
        # Bandwidths for checkpoint write by segment
        self.ckpt_writes = {}
        # Did EarlyStopping stop this node?
        self.stopped_early = False
        # Did the topN module find data for this Node?
        self.has_data = True
        # Did training complete for this node?
        self.complete = False
        # Can disable logging here:
        self.verbose = True
        # self.debug(logger, "START: " + str(self))

    def set_id(self, id, logger=None):
        self.id = id
        self.stage = (len(self.id) - 1) // 2
        # self.debug(logger, "SET ID: " + id)

    def new_segment(self):
        self.segment += 1

    def parent(self):
        if self.stage == 1:
            return None
        return self.id[0:-2]

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        special = ""
        if not self.has_data:
            special = "NO DATA!"
        else:
            if not self.complete:
                special = " INCOMPLETE!"
            if self.stopped_early:
                special = " EARLY STOP!"
        return "Node [%s]: %s (epochs=%i/%s, loss=%s, val_loss=%s)%s" % (
            Node.maybe_str_integer(self.stage),
            self.id,
            self.epochs_actual,
            Node.maybe_str_integer(self.epochs_planned),
            Node.maybe_str_float(self.loss, "%0.6f"),
            Node.maybe_str_float(self.val_loss, "%0.6f"),
            special,
        )

    def str_table(self):
        """Like str() but uses fixed-width fields."""
        special = ""
        if not self.has_data:
            return "%-13s : %i NO-DATA" % (self.id, self.stage)
        if not self.complete:
            special = " INCOMPLETE!"
        if self.stopped_early:
            special = " EARLY STOP!"
        return "%-13s : %i : %2s / %2s : %s - %s : %s : %s" % (
            self.id,
            self.stage,
            Node.maybe_str_integer(self.epochs_actual),
            Node.maybe_str_integer(self.epochs_planned),
            str(self.date_start),
            str(self.date_stop),
            self.str_errors(),
            special,
        )

    def str_errors(self):
        """Return errors as big string."""
        fmt = "%0.6f"
        s = ("loss: %s vl: %s mse: %s mae: %s r2: %s corr: %s") % (
            Node.maybe_str_float(self.loss, fmt),
            Node.maybe_str_float(self.val_loss, fmt),
            Node.maybe_str_float(self.mse, fmt),
            Node.maybe_str_float(self.mae, fmt),
            Node.maybe_str_float(self.r2, fmt),
            Node.maybe_str_float(self.corr, fmt),
        )
        return s

    def maybe_str_integer(i):
        if i is None:
            return "?"
        return str(i)

    def maybe_str_float(f, spec):
        if f is None:
            return "?"
        return spec % f

    def bad_line(self, line):
        print("")
        print("BAD LINE: " + line)
        print("")

    def parse_epochs(self, line, logger=None):
        tokens = line.split()
        self.epochs_planned = int(tokens[-1].strip())
        self.trace(logger, "epochs_planned: %i" % self.epochs_planned)

    def parse_load_initial(self, line, logger=None):
        tokens = line.split()
        self.load_initial = float(tokens[4])
        # print("load_initial: " + str(self.load_initial))

    def parse_epoch_status(self, line, logger=None):
        tokens = line.split()
        assert len(tokens) == 2, "bad line: " + line
        ints = tokens[1].split("/")
        assert len(tokens) == 2
        self.epochs_actual = int(ints[0])
        self.trace(logger, "epochs_actual: " + str(self.epochs_actual))

    def parse_current_time(self, line, logger=None):
        tokens = line.split()
        assert len(tokens) == 3, "bad line: " + line
        # Chop off leading dots: ....123.123
        t = tokens[2][4:]
        self.segments[self.segment] = float(t)
        # print("%-13s %i %r" % (self.id, self.segment, self.segments))

    def parse_model_write(self, line, logger=None):
        tokens = line.split()
        t = float(tokens[7][1:])
        self.ckpt_writes[self.segment] = t
        self.trace(logger, "model_write: %0.3f" % t)

    def stop_early(self, logger=None):
        self.stopped_early = True
        self.trace(logger, "STOP EARLY")

    def parse_date_start(self, line):
        tokens = line.split()
        self.date_start = tokens[0] + " " + tokens[1]

    def parse_date_stop(self, line, logger=None):
        tokens = line.split()
        self.date_stop = tokens[0] + " " + tokens[1]
        if self.epochs_planned is None:
            self.trace(logger, "STOP : epochs_planned=None")
            return
        if self.epochs_actual == self.epochs_planned or self.stopped_early:
            self.complete = True
            self.trace(logger, "COMPLETE")

    def parse_training_done(self, line, logger=None):
        # The current epoch should already be set
        #     by parse_epoch_status()
        # First, find the location of training_done (td)
        #      (to accommodate prefixes)
        try:
            tokens = line.split()
            td = 0
            while tokens[td] != Node.training_done:
                td = td + 1
            stepii = tokens[td - 1].split("/")
            self.steps += int(stepii[0])
            time_s = tokens[td + 2]  # e.g., "321s"
            self.time += int(time_s[0:-1])
            # Always collect losses: early stopping could happen:
            self.loss = float(tokens[td + 5])
            self.val_loss = float(tokens[td + 14])
        except Exception as e:
            self.bad_line(line)
            raise (e)

    def parse_val_data(self, fp):
        """fp is the file pointer to save/python.log If val data is not found,
        node.val_data will remain None."""
        marker = "val data = "
        marker_length = len(marker)
        while True:
            line = fp.readline()
            if line == "":
                break
            index = line.find("val data =")
            if index == -1:
                continue
            tail = line[index + marker_length:]
            comma = tail.find(",")
            value_string = tail[:comma]
            self.val_data = int(value_string)

    def parse_python_log(self, fp):
        """fp is the file pointer to save/python.log If lines are not found,
        node.mse, etc., will remain None."""
        marker = "Comparing y_true "
        # The marker is just after the date:
        # We search this way for speed.
        date_len = len("YYYY-MM-DD HH:MM:SS ")  # trailing space
        while True:
            line = fp.readline()
            if line == "":
                break
            if line.startswith("Epoch ", date_len) and \
               "lr=" in line:
                tokens = line.split("=")
                lr = float(tokens[1])
                # print("%s lr=%0.6f" % (self.id, lr))
                if self.lr_first is None:
                    self.lr_first = lr
                else:
                    self.lr_final = lr
            if line.startswith(marker, date_len):
                line = fp.readline()
                tokens = check_token(line, 2, "mse:")
                self.mse = float(tokens[3])
                # print("mse: " + str(self.mse))
                line = fp.readline()
                tokens = check_token(line, 2, "mae:")
                self.mae = float(tokens[3])
                line = fp.readline()
                tokens = check_token(line, 2, "r2:")
                self.r2 = float(tokens[3])
                line = fp.readline()
                tokens = check_token(line, 2, "corr:")
                self.corr = float(tokens[3])
            # Loop! We want the last such values in the file

    def get_loss_delta(node):
        if node.loss_delta is None:
            raise ValueError("No loss_delta!")
        return node.loss_delta

    def get_val_loss_delta(node):
        if node.val_loss_delta is None:
            raise ValueError("No val_loss_delta!")
        return node.val_loss_delta

    def debug(self, logger, message):
        # assert(logger != None) # Use this to find missing loggers
        if logger is None or not self.verbose:
            return
        logger.debug("NODE: [%s] %s" % (self.id, message))

    def trace(self, logger, message):
        # assert(logger != None) # Use this to find missing loggers
        if logger is None or not self.verbose:
            return
        import logging

        logger.log(level=logging.DEBUG - 5,
                   msg=("NODE: [%s] %s" % (self.id, message)))

    def get_time_cumul(self, nodes):
        """Time cumulative including parents' time."""
        parent = self.parent()
        if parent is None:
            return self.time
        return self.time + nodes[parent].get_time_cumul(nodes)

    def get_segments(self):
        total = 0
        for s, t in self.segments.items():
            total += t
        return total

    def get_epochs_cumul(self, nodes):
        """Epochs cumulative including parents' epochs."""
        if self.epochs_cumul is not None:
            return self.epochs_cumul
        # Initialize:
        self.epochs_cumul = self.epochs_actual
        parent = self.parent()
        if parent is not None and parent in nodes:
            # Add parents:
            self.epochs_cumul += nodes[parent].get_epochs_cumul(nodes)
        return self.epochs_cumul


def check_token(line, index, token):
    """Assert that token is in line at given index."""
    tokens = line.split()
    if tokens[index] != token:
        raise Exception(
            ("could not find token: '%s'\n" + "in line: '%s'") % (token, line))
    return tokens


def check(condition, message):
    """Check condition or raise Exception with given message."""
    if not condition:
        raise Exception(message)


# EXAMPLES:

# __init__()

# 2019-12-14 09:46:32 MODEL RUNNER DEBUG  node = 1.4.2.1

# parse_epochs() ==> self.epochs_planned

# 2019-12-14 09:46:32 MODEL RUNNER DEBUG  epochs = 5

# parse_epoch_status() (from Keras)

# Epoch 29/50

# parse_val_data() ==> self.val_data

# 2020-04-15 13:45:41 CV fold 0: train data = 5265, val data = 1400, test data = 0

# stop_early()

# Epoch 00004: early stopping

# training_done()

# 16092/16092 [==============================] - 315s 20ms/step - loss: 0.0065 - mae: 0.0565 - r2: -0.6208 - val_loss: 0.0139 - val_mae: 0.0575 - val_r2: -0.3959

# ==> self.epochs_actual, self.val_loss, self.time, self.complete
