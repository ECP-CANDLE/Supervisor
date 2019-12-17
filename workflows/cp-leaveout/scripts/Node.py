
# NODE PY

# The training node information as stored in the logs
# See the footer of this file for example log text that is parsed here

import math

class Node:

    # TensorFlow is done when you see this
    training_done = "[==============================]" 
    
    def __init__(self, node_id):
        self.id = node_id
        # Use string length of id to deduce stage:
        self.stage = (len(self.id) - 1) / 2
        self.steps = 0
        self.val_loss = 0
        self.epochs_planned = 0
        self.epochs_actual  = 0
        self.time = 0
        self.stopped_early = False # Did EarlyStopping stop this node?
        self.complete = False # Did training complete for this node?
        self.verbose = False
        self.debug("START: " + str(self))

    def __str__(self):
        special = ""
        if not self.complete:
            special = " INCOMPLETE!"
        if self.stopped_early:
            special = " EARLY STOP!"
        return "Node [%i]: %s (epochs=%i/%i, val_loss=%0.4f)%s" % \
            (self.stage, self.id,
             self.epochs_actual, self.epochs_planned,
             self.val_loss, special)

    def str_table(self):
        special = ""
        if not self.complete:
            special = " INCOMPLETE!"
        if self.stopped_early:
            special = " EARLY STOP!"
        return "%-10s : %i : %2i / %2i : %0.4f : %s" % \
            (self.id, self.stage, 
             self.epochs_actual, self.epochs_planned,
             self.val_loss, special)
            
    def parse_epochs(self, line):
        tokens = line.split()
        self.epochs_planned = int(tokens[-1].strip())
        self.debug("epochs_planned: %i" % self.epochs_planned)

    def stop_early(self):
        self.stopped_early = True
        self.complete = True
        self.debug("STOP EARLY")
        
    def parse_training_done(self, line):
        self.epochs_actual += 1
        # Find the location of training_done (td) (to accommodate prefixes)
        tokens = line.split()
        td = 0
        while tokens[td] != Node.training_done:
            td = td + 1
        stepii = tokens[td-1].split("/")
        self.steps += int(stepii[0])
        time_s = tokens[td+2] # e.g., "321s"
        self.time += int(time_s[0:-1])
        # Always collect val_loss: early stopping could happen:
        self.val_loss = float(tokens[td+15])
        if self.epochs_actual == self.epochs_planned:
            self.complete = True
            self.debug("COMPLETE")

    def debug(self, message):
        if not self.verbose:
            return
        print("NODE: " + message)

'''
EXAMPLES:

__init__()

2019-12-14 09:46:32 MODEL RUNNER DEBUG  node = 1.4.2.1

parse_epochs()

2019-12-14 09:46:32 MODEL RUNNER DEBUG  epochs = 5

stop_early()

Epoch 00004: early stopping

training_done()

16092/16092 [==============================] - 315s 20ms/step - loss: 0.0065 - mae: 0.0565 - r2: -0.6208 - val_loss: 0.0139 - val_mae: 0.0575 - val_r2: -0.3959
'''
