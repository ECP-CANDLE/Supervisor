import sys
import p1b1_baseline_keras2
import p1b1

if (len(sys.argv) < 3):
	print('requires arg1=param and arg2=filename')
	sys.exit(1)

parameterString = sys.argv[1]
filename        = sys.argv[2]

print (parameterString)
print ("filename is ", filename)


integs = [int(x) for x in parameterString.split(',')]
print (integs)

epochs = integs[0]
batch_size = integs[1]
N1 = integs[2]
NE = integs[3]

print ("Starting to loading Xtrain and Xtest")
X_train, X_test = p1b1.load_data()
print ("Done loading Xtrain and Xtest")

print ("Running p1b1 for epochs, batch_size, N1, NE", epochs, batch_size, N1, NE)
# Need to introduce N1 and NE as parameters to the run_p1b1 function
encoder, decoder, history = p1b1_baseline_keras2.run_p1b1(X_train, X_test, epochs=epochs, batch_size=batch_size)
print ("Done running p1b1")

# works around this error:
# https://github.com/tensorflow/tensorflow/issues/3388
from keras import backend as K
K.clear_session()

# use the last validation_loss as the value to minimize
val_loss = history.history['val_loss']
r = val_loss[-1]

# writing the val loss to the output file
with open(filename, 'w') as the_file:
    the_file.write(repr(r))

