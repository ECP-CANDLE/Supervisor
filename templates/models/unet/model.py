# Import relevant modules
from keras import backend as K
import numpy as np

# Parameters
candle_lib = '/data/BIDS-HPC/public/candle/Candle/common'

def initialize_parameters():
    print('Initializing parameters...')

    import os

    # Obtain the path of the directory of this script
    file_path = os.path.dirname(os.path.realpath(__file__))

    # Import the CANDLE library
    import sys
    sys.path.append(candle_lib)
    import candle_keras as candle

    # Instantiate the candle.Benchmark class
    mymodel_common = candle.Benchmark(file_path,os.getenv("DEFAULT_PARAMS_FILE"),'keras',prog='myprog',desc='My model')

    # Get a dictionary of the model hyperparamters
    gParameters = candle.initialize_parameters(mymodel_common)

    # Return the dictionary of the hyperparameters
    return(gParameters)

def run(gParameters):
    print('Running model...')

    #### Begin model input ##########################################################################################
    # Currently based off run_unet.py

    def focal_loss(labels, logits, gamma=0, alpha=1.0):
        """
        focal loss for multi-classification
        FL(p_t)=-alpha(1-p_t)^{gamma}ln(p_t)
        Notice: logits is probability after softmax
        gradient is d(Fl)/d(p_t) not d(Fl)/d(x) as described in paper
        d(Fl)/d(p_t) * [p_t(1-p_t)] = d(Fl)/d(x)
    
        Focal Loss for Dense Object Detection, 
        https://doi.org/10.1016/j.ajodo.2005.02.022
    
        :param labels: ground truth labels, shape of [batch_size]
        :param logits: model's output, shape of [batch_size, num_cls]
        :param gamma:
        :param alpha:
        :return: shape of [batch_size]
        """

        import tensorflow as tf

        epsilon = 1.e-9
        labels = tf.to_int64(labels)
        labels = tf.convert_to_tensor(labels, tf.int64)
        logits = tf.convert_to_tensor(logits, tf.float32)
        num_cls = logits.shape[1]
    
        model_out = tf.add(logits, epsilon)
        onehot_labels = tf.one_hot(labels, num_cls)
        ce = tf.multiply(onehot_labels, -tf.log(model_out))
        weight = tf.multiply(onehot_labels, tf.pow(tf.subtract(1., model_out), gamma))
        fl = tf.multiply(alpha, tf.multiply(weight, ce))
        reduced_fl = tf.reduce_max(fl, axis=1)
        # reduced_fl = tf.reduce_sum(fl, axis=1)  # same as reduce_max
        return reduced_fl

    def dice_coef(y_true, y_pred):
        smooth = 1.
        intersection = K.sum(y_true * y_pred, axis=[1,2,3])
        union = K.sum(y_true, axis=[1,2,3]) + K.sum(y_pred, axis=[1,2,3]) 
        dc = K.mean( (2. * intersection + smooth) / (union + smooth), axis=0)
        return dc

    def dice_coef_loss(y_true, y_pred):
        return -dice_coef(y_true, y_pred)

    def get_unet(img_rows, img_cols, n_layers, filter_size, dropout, activation_func, conv_size, loss_func, last_activation, batch_norm, learning_rate):

        print('-'*30)
        print('Creating and compiling model...')
        print('-'*30)
        print (img_rows)
        print (img_cols)

        inputs = Input((img_rows, img_cols, 1))
        conv_layers=[] 
        pool_layers=[inputs]
        conv_filter=(conv_size, conv_size )

        for i in range(n_layers):
            conv = Conv2D(filter_size,  conv_filter, activation=activation_func, padding='same')(pool_layers[i])
            conv = BatchNormalization()(conv) if batch_norm else conv
            if dropout != None:
                conv = Dropout(dropout)(conv)
            conv = Conv2D(filter_size, conv_filter, activation=activation_func, padding='same')(conv)
            conv = BatchNormalization()(conv) if batch_norm else conv
            pool = MaxPooling2D(pool_size=(2, 2))(conv)
            conv_layers.append(conv)
            pool_layers.append(pool)
            filter_size *=2
            
        filter_size /=4

        for i in range(n_layers-1):
            filter_size = int(filter_size)
            up = concatenate([Conv2DTranspose(filter_size, (2, 2), strides=(2, 2), padding='same')(conv_layers[-1]), conv_layers[n_layers-i-2]], axis=3)
            conv = Conv2D(filter_size, conv_filter, activation=activation_func, padding='same')(up)
            conv = BatchNormalization()(conv) if batch_norm else conv
            if dropout != None:  
                conv = Dropout(dropout)(conv)
            conv = Conv2D(filter_size, conv_filter, activation=activation_func, padding='same')(conv)
            conv = BatchNormalization()(conv) if batch_norm else conv
            conv_layers.append(conv)
            filter_size /= 2

        #For binary classification, last activation should be sigmoid. 
        #    if loss_func  == 'dice':
        #        last_activation = 'sigmoid'
        #    else:
        #        print ("WARNING: last_activation set to None")
        #        last_activation = None

        last_conv =  Conv2D(1, (1, 1), activation=last_activation)(conv_layers[-1])
        conv_layers.append(last_conv)
        
        model = Model(inputs=[inputs], outputs=[last_conv])
        
        if loss_func == 'dice':
            model.compile(optimizer=Adam(lr=learning_rate), loss=dice_coef_loss, metrics=[dice_coef])
        else:
            #Any Keras loss function will be passed
            model.compile(optimizer=Adam(lr=learning_rate), loss = loss_func)
        model.summary()
        model_json = model.to_json()
        with open("model.json", "w") as json_file:
            json_file.write(model_json)
        return model

    def get_images(images, masks, normalize_mask=False):

        print('-'*30)
        print('Loading and preprocessing train data...')
        print('-'*30)

        imgs_train = preprocess_images(images) 
        imgs_mask_train = preprocess_masks(masks, normalize_mask) 

        #Shuffle the images
        np.random.seed(10)
        shuffled_id = np.random.permutation(imgs_train.shape[0])
        imgs_train = imgs_train[shuffled_id]
        imgs_mask_train = imgs_mask_train[shuffled_id]

        assert(np.amax(imgs_mask_train) <= 1)
        assert(np.amin(imgs_mask_train) >=  0)
        return_images = imgs_train 
        return_masks = imgs_mask_train 

        print (np.shape(return_images))
        print (np.shape(return_masks))
        return [return_images, return_masks]

    def evaluate_params(images, labels, batch_size, epochs, obj_return, initialize, n_layers, filter_size, dropout, activation_func, conv_size, loss_func, last_activation, batch_norm, learning_rate):

        images , masks = get_images(images,labels)
        
        print("Training images histogram") 
        hist, bin_edges = np.histogram(images)
        print(hist)
        print(bin_edges)
        
        print("Training masks histogram") 
        hist, bin_edges = np.histogram(masks)
        print(hist)
        print(bin_edges)
        
        #Get the images size  
        img_rows = np.shape(images)[1]
        img_cols = np.shape(images)[2]
        
        model = get_unet(img_rows, img_cols, n_layers, filter_size, dropout, activation_func, conv_size, loss_func, last_activation, batch_norm, learning_rate)
        
        history_callback = train(model, images, masks, batch_size, epochs, obj_return, initialize=initialize)
        return history_callback # note that history_callback is what's returned by model.fit()

    def preprocess_images(images):
        imgs_train = np.squeeze(np.load(images))
        if imgs_train.ndim != 3:
            raise Exception("Error: The number of dimensions for images should equal 3, after squeezing the shape is:{0}".format(np.shape(images)))
        imgs_train = imgs_train.astype('float32')
        print("MAX before:{0}".format(np.amax(imgs_train)))
        #Normalize all number between 0 and 1.
        uint16_info = np.iinfo('uint16')
        imgs_train = imgs_train / uint16_info.max
        print("MAX after:{0}".format(np.amax(imgs_train)))
        imgs_train = np.expand_dims(imgs_train, axis= 3)
        return imgs_train

    def preprocess_masks(masks, normalize_mask=False):
        imgs_mask_train = np.squeeze(np.load(masks))
        if imgs_mask_train.ndim != 3:
            raise Exception("Error: The number of dimensions for masks should equal 3, after squeezing the shape is:{0}".format(np.shape(masks)))
        imgs_mask_train = imgs_mask_train.astype('float32')
        if normalize_mask:
            imgs_mask_train /= 255.  # scale masks to [0, 1]
        imgs_mask_train = np.expand_dims(imgs_mask_train, axis= 3)
        return imgs_mask_train

    def train(model, imgs_train, imgs_mask_train, batch_size, epochs, obj_return, initialize=None):

        model_checkpoint = ModelCheckpoint(modelwtsfname, monitor=obj_return, save_best_only=True)
        reduce_lr = ReduceLROnPlateau(monitor=obj_return, factor=0.1,patience=100, verbose=1)
        model_es = EarlyStopping(monitor=obj_return, min_delta=0.000001, patience=400, verbose=1, mode='auto')
        csv_logger = CSVLogger('training.csv')
        
        print('-'*30)
        print('Fitting model...')
        print('-'*30)
        
        if initialize != None:
            print("Initializing the model using:{0}\n", initialize)
            model.load_weights(initialize)
            
        #test_call=TestCallback((imgs_train,imgs_mask_train))
        
        print(np.shape(imgs_train))
        print(np.shape(imgs_mask_train))
        #return model.fit(imgs_train, imgs_mask_train, batch_size=2, epochs=3000, verbose=2, shuffle=True,
        return model.fit(imgs_train, imgs_mask_train, batch_size=batch_size, epochs=epochs, verbose=2, shuffle=True,
        #return model.fit(imgs_train, imgs_mask_train, batch_size=2, epochs=1500, verbose=2, shuffle=True,
        #return model.fit(imgs_train, imgs_mask_train, batch_size=2, epochs=4, verbose=2, shuffle=True,
              validation_split=0.10, callbacks=[model_checkpoint, reduce_lr, model_es, csv_logger])

    def predict(model, weights, images):
        print('-'*30)
        print('Loading and preprocessing test data...')
        print('-'*30)

        #imgs_test = np.load('./data_python/1CDT_Green_Red_FarRed_Annotated_FISH_Dilation4Conn1Iter_Testing_128by128_normalize.npy')
        #imgs_mask_test = np.load('.//data_python/1CDT_Green_Red_FarRed_Annotated_FISH_Dilation4Conn1Iter_Testing_128by128_normalize_Mask.npy')
        #imgs_test = imgs_test.astype('float32')
        
        #imgs_train = np.load('../data_python/1CDT_Green_Red_Annotated_FISH_Dilation8Conn1Iter_Training_128by128.npy')
        #imgs_train = imgs_train.astype('float32')
        #mean = np.mean(imgs_train)  # mean for data centering
        #std = np.std(imgs_train)  # std for data normalization
        #del imgs_train
        #imgs_test -= mean
        #imgs_test /= std

        print('-'*30)
        print('Loading saved weights...')
        print('-'*30)

        model.load_weights(weights)

        print('-'*30)
        print('Predicting masks on test data...')
        print('-'*30)
        #imgs_test = np.expand_dims(imgs_test,3)

        print ('{0}'.format(np.shape(images)))
        print ('{0}'.format(type(images)))


        print("Inference images histogram") 
        hist, bin_edges = np.histogram(images)
        print(hist)
        print(bin_edges)

        imgs_mask_test = model.predict(images, batch_size = 1,verbose=1)

        print("Inference predictions histogram") 
        hist, bin_edges = np.histogram(imgs_mask_test)
        print(hist)
        print(bin_edges)
    
        #np.save('mask_predictions.npy', np.squeeze(imgs_mask_test))
        np.save('mask_predictions.npy', np.squeeze(np.round(imgs_mask_test).astype('uint8')))

    # Import relevant modules and functions
    from keras.models import Model
    from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, Dropout, BatchNormalization
    from keras.optimizers import Adam
    from keras.callbacks import ModelCheckpoint,ReduceLROnPlateau,EarlyStopping, CSVLogger, Callback
    import pickle

    # Basically a constant
    modelwtsfname = 'model_weights.h5'

    if not gParameters['predict']:
        print('Training...')

        # Parameters
        n_layers = gParameters['nlayers']
        filter_size = gParameters['num_filters']
        dropout = gParameters['dropout']
        activation_func = gParameters['activation']
        conv_size = gParameters['conv_size']
        loss_func = gParameters['loss_func']
        last_activation = gParameters['last_act']
        batch_norm = gParameters['batch_norm']
        learning_rate = float(gParameters['lr'])
        images = gParameters['images']
        labels = gParameters['labels']
        batch_size = gParameters['batch_size']
        epochs = gParameters['epochs']
        obj_return = gParameters['obj_return']
        initialize = gParameters['initialize']

        history_callback = evaluate_params(images, labels, batch_size, epochs, obj_return, initialize, n_layers, filter_size, dropout, activation_func, conv_size, loss_func, last_activation, batch_norm, learning_rate) # note that history_callback is what's returned by model.fit()
        print("Minimum validation loss:")
        print(min(history_callback.history[obj_return]))
        #Save the history as pickle object
        pickle.dump(history_callback.history, open( "fit_history.p", "wb" ) )
    else:
        print('Inferring...')

        # Parameters
        n_layers = gParameters['nlayers']
        filter_size = gParameters['num_filters']
        dropout = gParameters['dropout']
        activation_func = gParameters['activation']
        conv_size = gParameters['conv_size']
        loss_func = gParameters['loss_func']
        last_activation = gParameters['last_act']
        batch_norm = gParameters['batch_norm']
        learning_rate = float(gParameters['lr'])
        images = gParameters['images']
        initialize = gParameters['initialize']

        #It is not necessary to pass masks for prediction, but I am just following the function
        #prototype for now.
        images = preprocess_images(images)
        #Get the images size  
        img_rows = np.shape(images)[1]
        img_cols = np.shape(images)[2]
        model = get_unet(img_rows, img_cols, n_layers, filter_size, dropout, activation_func, conv_size, loss_func, last_activation, batch_norm, learning_rate)
        weights = initialize
        predict(model, weights, images)
        history_callback = None
    
    #### End model input ############################################################################################
    
    return(history_callback)

def main():
    print('Running main program...')
    gParameters = initialize_parameters()
    run(gParameters)

if __name__ == '__main__':
    main()
    try:
        K.clear_session()
    except AttributeError:
        pass