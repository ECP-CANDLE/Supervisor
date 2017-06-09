import sys
import p1b1_runner
import json


if (len(sys.argv) < 3):
	print('requires arg1=param and arg2=filename')
	sys.exit(1)

parameterString = sys.argv[1]
filename        = sys.argv[2]

# print (parameterString)
print ("filename is " + filename)


integs = [int(x) for x in parameterString.split(',')]
print (integs)

hyper_parameter_map = {'epochs' : integs[0]}
hyper_parameter_map['framework'] = 'keras'
hyper_parameter_map['batch_size'] = integs[1]
hyper_parameter_map['dense'] = [integs[2], integs[3]] 
hyper_parameter_map['save'] = './output'

val_loss = p1b1_runner.run(hyper_parameter_map)
print (val_loss)
# works around this error:
# https://github.com/tensorflow/tensorflow/issues/3388
from keras import backend as K
K.clear_session()

# writing the val loss to the output file
with open(filename, 'w') as the_file:
    the_file.write(repr(val_loss))

