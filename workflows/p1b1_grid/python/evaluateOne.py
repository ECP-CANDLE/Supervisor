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

epochs = int(parameterString[0].strip())
batch_size = int(parameterString[2].strip())
print ("Running p1b1 for epochs ", epochs, batch_size)

# N1 = int(parameterString[2].strip())
# NE = int(parameterString[3].strip())

print("Set the correct paths for test and train file")
test_path="/home/jain/Benchmarks/Data/Pilot1/P1B1.test.csv"
train_path="/home/jain/Benchmarks/Data/Pilot1/P1B1.train.csv"

print ("Starting to loading Xtrain and Xtest")
X_train, X_test = p1b1.load_data(test_path=test_path, train_path=train_path)
print ("Done loading Xtrain and Xtest")

print ("Running p1b1 for epochs ", epochs)
encoder, decoder, history = p1b1_baseline_keras2.run_p1b1(X_train, X_test, epochs=epochs, batch_size=batch_size)
print ("Done running p1b1 for epochs ", epochs)

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

