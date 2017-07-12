import sys
import json, os
import socket


if (len(sys.argv) < 3):
	print('requires arg1=param and arg2=filename')
	sys.exit(1)

parameterString = sys.argv[1]
filename        = sys.argv[2]
benchmarkName   = sys.argv[3]

integs = [float(x) for x in parameterString.split(',')]

if (benchmarkName == "p1b1"):
	import p1b1_runner
	hyper_parameter_map = {'epochs' : int(integs[0])}
	hyper_parameter_map['framework'] = 'keras'
	hyper_parameter_map['batch_size'] = int(integs[1])
	hyper_parameter_map['dense'] = [int(integs[2]), int(integs[3])] 
	hyper_parameter_map['run_id'] = parameterString
	# hyper_parameter_map['instance_directory'] = os.environ['TURBINE_OUTPUT'] 
	hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid())
	sys.argv = ['p1b1_runner']
	val_loss = p1b1_runner.run(hyper_parameter_map)
elif (benchmarkName == "p1b3"):
	import p1b3_runner
	hyper_parameter_map = {'epochs' : int(integs[0])}
	hyper_parameter_map['framework'] = 'keras'
	hyper_parameter_map['batch_size'] = int(integs[1])
	hyper_parameter_map['test_cell_split'] = int(integs[2])
	hyper_parameter_map['drop'] = int(integs[3])
	hyper_parameter_map['run_id'] = parameterString
	# hyper_parameter_map['instance_directory'] = os.environ['TURBINE_OUTPUT'] 
	hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid())
	sys.argv = ['p1b3_runner']
	val_loss = p1b3_runner.run(hyper_parameter_map)
elif (benchmarkName == "p2b1"):
	import p2b1_runner
	hyper_parameter_map = {'epochs' : int(integs[0])}
	hyper_parameter_map['framework'] = 'keras'
	hyper_parameter_map['batch_size'] = int(integs[1])
	hyper_parameter_map['molecular_epochs'] = int(integs[2])
	hyper_parameter_map['weight_decay'] = integs[3]
	hyper_parameter_map['run_id'] = parameterString
	hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid())
	sys.argv = ['p2b1_runner']
	val_loss = p2b1_runner.run(hyper_parameter_map)
elif (benchmarkName == "nt3"):
	import nt3_tc1_runner
	hyper_parameter_map = {'epochs' : int(integs[0])}
	hyper_parameter_map['framework'] = 'keras'
	hyper_parameter_map['batch_size'] = int(integs[1])
	hyper_parameter_map['classes'] = int(integs[2])
	hyper_parameter_map['model_name'] = 'nt3'	
	hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid())
	sys.argv = ['nt3_runner']
	val_loss = nt3_tc1_runner.run(hyper_parameter_map)
elif (benchmarkName == "p3b1"):
	import p3b1_runner
	hyper_parameter_map = {'epochs' : int(integs[0])}
	hyper_parameter_map['framework'] = 'keras'
	hyper_parameter_map['batch_size'] = int(integs[1])
	hyper_parameter_map['run_id'] = parameterString
	# hyper_parameter_map['instance_directory'] = os.environ['TURBINE_OUTPUT'] 
	hyper_parameter_map['save'] = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid())
	sys.argv = ['p3b1_runner']
	val_loss = p3b1_runner.run(hyper_parameter_map)

# print (parameterString)
# print ("filename is " + filename)
# print (str(os.getpid()))
print (val_loss)

# sfn = os.environ['TURBINE_OUTPUT']+ "/output-"+str(os.getpid()) + "/procname-" + parameterString
# with open(sfn, 'w') as sfile:
#     sfile.write(socket.getfqdn())
#     proc_id = "-"+ str(os.getpid())
#     sfile.write(proc_id)

# works around this error:
# https://github.com/tensorflow/tensorflow/issues/3388
from keras import backend as K
K.clear_session()

# writing the val loss to the output file (result-*)
with open(filename, 'w') as the_file:
    the_file.write(repr(val_loss))

