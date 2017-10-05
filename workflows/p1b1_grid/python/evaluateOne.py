import sys
import p1b1_runner
import json, os
import socket

if (len(sys.argv) < 3):
	print('requires arg1=param and arg2=filename')
	sys.exit(1)

parameterString = sys.argv[1]
filename        = sys.argv[2]

# print (parameterString)
print ("filename is " + filename)
print (socket.gethostname())

#List of hyperparameters - edit this to add or remove a parameter
epochs, batch_size, d1, d2, ld, lr = parameterString.split(',')

hyper_parameter_map = {'epochs' : int(epochs)}
hyper_parameter_map['framework'] = 'keras'
hyper_parameter_map['batch_size'] = int(batch_size)
hyper_parameter_map['dense'] = [int(d1), int(d2)] 
hyper_parameter_map['latent_dim'] = int(ld)
hyper_parameter_map['learning_rate'] = float(lr)

hyper_parameter_map['run_id'] = parameterString
# hyper_parameter_map['instance_directory'] = os.environ['TURBINE_OUTPUT'] 
hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+os.environ['PMI_RANK']
sys.argv = ['p1b1_runner']
val_loss = p1b1_runner.run(hyper_parameter_map)
print (val_loss)

sfn = os.environ['TURBINE_OUTPUT']+ "/output-"+os.environ['PMI_RANK'] + "/procname-" + parameterString
with open(sfn, 'w') as sfile:
    sfile.write(socket.getfqdn())
    proc_id = "-"+ str(os.getpid())
    sfile.write(proc_id)

# works around this error:
# https://github.com/tensorflow/tensorflow/issues/3388
from keras import backend as K
K.clear_session()

# writing the val loss to the output file (result-*)
with open(filename, 'w') as the_file:
    the_file.write(repr(val_loss))

