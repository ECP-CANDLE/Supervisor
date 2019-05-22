# Find and load the wrapper_connector module in order to source the functions that read/write JSON files
import sys, os
sys.path.append(os.getenv("CANDLE")+'/Supervisor/templates/scripts')
import wrapper_connector
gParameters = wrapper_connector.load_params('params.json')
################ ADD MODEL BELOW USING gParameters DICTIONARY AS CURRENT HYPERPARAMETER SET; DO NOT MODIFY ABOVE #######################################


##########################################
# Your DL start here. See mnist_mlp.py   #
##########################################
'''Trains a simple deep NN on the MNIST dataset.

Gets to 98.40% test accuracy after 20 epochs
(there is *a lot* of margin for parameter tuning).
2 seconds per epoch on a K520 GPU.
'''

import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import RMSprop

batch_size = gParameters['batch_size']
num_classes = 10
epochs = gParameters['epochs']

activation = gParameters['activation']
optimizer = gParameters['optimizer']

# the data, split between train and test sets
(x_train, y_train), (x_test, y_test) = mnist.load_data()

x_train = x_train.reshape(60000, 784)
x_test = x_test.reshape(10000, 784)
x_train = x_train.astype('float32')
x_test = x_test.astype('float32')
x_train /= 255
x_test /= 255
print(x_train.shape[0], 'train samples')
print(x_test.shape[0], 'test samples')

# convert class vectors to binary class matrices
y_train = keras.utils.to_categorical(y_train, num_classes)
y_test = keras.utils.to_categorical(y_test, num_classes)

model = Sequential()
model.add(Dense(512, activation=activation, input_shape=(784,)))
model.add(Dropout(0.2))
model.add(Dense(512, activation=activation))
model.add(Dropout(0.2))
model.add(Dense(num_classes, activation='softmax'))

model.summary()

model.compile(loss='categorical_crossentropy',
            optimizer=optimizer,
            metrics=['accuracy'])

history = model.fit(x_train, y_train,
                    batch_size=batch_size,
                    epochs=epochs,
                    verbose=1,
                    validation_data=(x_test, y_test))
score = model.evaluate(x_test, y_test, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])
##########################################
# End of mnist_mlp.py ####################
##########################################


################ ADD MODEL ABOVE USING gParameters DICTIONARY AS CURRENT HYPERPARAMETER SET; DO NOT MODIFY BELOW #######################################
# Ensure that above you DEFINE the history object (as in, e.g., the return value of model.fit()) or val_to_return (a single number) in your model; below we essentially RETURN those values
try: history
except NameError:
    try: val_to_return
    except NameError:
        print("Error: Neither a history object nor a val_to_return variable was defined upon running the model on the current hyperparameter set; exiting")
        exit
    else:
        wrapper_connector.write_history_from_value(val_to_return, 'val_to_return.json')
else:
    wrapper_connector.write_history(history, 'val_to_return.json')