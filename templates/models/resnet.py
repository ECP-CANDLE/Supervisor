from __future__ import print_function

from keras import backend as K
import os

# Parameters
candle_lib = '/data/BIDS-HPC/public/candle/Candle/common'

def initialize_parameters():
    print('Initializing parameters...')
    
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
    
    def get_model(model_json_fname,modelwtsfname):
        # This is only for prediction
        if os.path.isfile(model_json_fname):
             # Model reconstruction from JSON file
             with open(model_json_fname, 'r') as f:
                model = model_from_json(f.read())
        else:
             model = get_unet()
        
        #model.summary()     
        # Load weights into the new model
        model.load_weights(modelwtsfname)
        return model      
    
    def focal_loss(gamma=2., alpha=.25):
        def focal_loss_fixed(y_true, y_pred):
            pt_1 = tf.where(tf.equal(y_true, 1), y_pred, tf.ones_like(y_pred))
            pt_0 = tf.where(tf.equal(y_true, 0), y_pred, tf.zeros_like(y_pred))
            return -K.sum(alpha * K.pow(1. - pt_1, gamma) * K.log(pt_1))-K.sum((1-alpha) * K.pow( pt_0, gamma) * K.log(1. - pt_0))
        return focal_loss_fixed
    
    def jaccard_coef(y_true, y_pred):
        smooth = 1.0
        intersection = K.sum(y_true * y_pred, axis=[-0, -1, 2])
        sum_ = K.sum(y_true + y_pred, axis=[-0, -1, 2])
    
        jac = (intersection + smooth) / (sum_ - intersection + smooth)
    
        return K.mean(jac)
    
    def jaccard_coef_int(y_true, y_pred):
        smooth = 1.0
        y_pred_pos = K.round(K.clip(y_pred, 0, 1))
    
        intersection = K.sum(y_true * y_pred_pos, axis=[-0, -1, 2])
        sum_ = K.sum(y_true + y_pred_pos, axis=[-0, -1, 2])
    
        jac = (intersection + smooth) / (sum_ - intersection + smooth)
    
        return K.mean(jac)
    
    def jaccard_coef_loss(y_true, y_pred):
        return -K.log(jaccard_coef(y_true, y_pred)) + binary_crossentropy(y_pred, y_true)
    
    def dice_coef_batch(y_true, y_pred):
        smooth = 1.0
        intersection = K.sum(y_true * y_pred, axis=[-0, -1, 2])
        sum_ = K.sum(y_true + y_pred, axis=[-0, -1, 2])
    
        dice = ((2.0*intersection) + smooth) / (sum_ + intersection + smooth)
    
        return K.mean(dice)
    
    def dice_coef(y_true, y_pred):
        smooth = 1.0
        y_true_f = K.flatten(y_true)
        y_pred_f = K.flatten(y_pred)
        intersection = K.sum(y_true_f * y_pred_f)
        dice_smooth = ((2. * intersection) + smooth) / (K.sum(y_true_f) + K.sum(y_pred_f) + smooth)
        return (dice_smooth)
    
    def dice_coef_loss(y_true, y_pred):
        return -dice_coef(y_true, y_pred)
    
    def dice_coef_batch_loss(y_true, y_pred):
        return -dice_coef_batch(y_true, y_pred)
    
    #Define the neural network
    def get_unet():
        droprate = 0.25
        filt_size = 32
        inputs = Input((None, None, 1))
        conv1 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(inputs)
        conv1 = Dropout(droprate)(conv1) 
        conv1 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv1)
        pool1 = MaxPooling2D(pool_size=(2, 2))(conv1)
        filt_size = filt_size*2
    
        conv2 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(pool1)
        conv2 = Dropout(droprate)(conv2) 
        conv2 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv2)
        pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)
        filt_size = filt_size*2
    
        conv3 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(pool2)
        conv3 = Dropout(droprate)(conv3) 
        conv3 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv3)
        pool3 = MaxPooling2D(pool_size=(2, 2))(conv3)
        filt_size = filt_size*2
    
        conv4 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(pool3)
        conv4 = Dropout(droprate)(conv4) 
        conv4 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv4)
        pool4 = MaxPooling2D(pool_size=(2, 2))(conv4)
        filt_size = filt_size*2
        
        conv5 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(pool4)
        conv5 = Dropout(droprate)(conv5)
        conv5 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv5)
    
        filt_size = filt_size/2
    
        up6 = concatenate([Conv2DTranspose(filt_size, (2, 2), strides=(2, 2), padding='same')(conv5), conv4], axis=3)
        conv6 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(up6)
        conv6 = Dropout(droprate)(conv6)
        conv6 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv6)
    
        filt_size = filt_size/2
    
        up7 = concatenate([Conv2DTranspose(filt_size, (2, 2), strides=(2, 2), padding='same')(conv6), conv3], axis=3)
        conv7 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(up7)
        conv7 = Dropout(droprate)(conv7)
        conv7 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv7)
    
        filt_size = filt_size/2
        
        up8 = concatenate([Conv2DTranspose(filt_size, (2, 2), strides=(2, 2), padding='same')(conv7), conv2], axis=3)
        conv8 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(up8)
        conv8 = Dropout(droprate)(conv8)
        conv8 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv8)
        filt_size = filt_size/2
        
        up9 = concatenate([Conv2DTranspose(filt_size, (2, 2), strides=(2, 2), padding='same')(conv8), conv1], axis=3)
        conv9 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(up9)
        conv9 = Dropout(droprate)(conv9)
        conv9 = Conv2D(filt_size, (3, 3), activation='relu', padding='same')(conv9)
    
        
        conv10 = Conv2D(1, (1, 1), activation='sigmoid')(conv9)
        
        model = Model(inputs=[inputs], outputs=[conv10])
    
        #model.compile(optimizer=Adam(lr=1e-5), loss=dice_coef_loss, metrics=[dice_coef])
        #model.compile(optimizer=Nadam(lr=1e-3), loss=dice_coef_loss, metrics=[dice_coef])
        #model.compile(optimizer=Adadelta(), loss=dice_coef_loss, metrics=[dice_coef])
        
        return model
    
    def save_model_to_json(model,model_json_fname):
        
        #model = unet.UResNet152(input_shape=(None, None, 3), classes=1,encoder_weights="imagenet11k")	
        #model = get_unet()
        
        #model.summary()
        # serialize model to JSON
        model_json = model.to_json()
        with open(model_json_fname, "w") as json_file:
             json_file.write(model_json)
    
    def preprocess_data(do_prediction,inputnpyfname,targetnpyfname,expandChannel,backbone):
        # Preprocess the data (beyond what I already did before)
        
        print('-'*30)
        print('Loading and preprocessing data...')
        print('-'*30)
    
        # Load, normalize, and cast the data
        imgs_input = ( np.load(inputnpyfname).astype('float32') / (2**16-1) * (2**8-1) ).astype('uint8')
        print('Input images information:')
        print(imgs_input.shape)
        print(imgs_input.dtype)
        hist,bins = np.histogram(imgs_input)
        print(hist)
        print(bins)
        if not do_prediction:
            imgs_mask_train = np.load(targetnpyfname).astype('uint8')
            print('Input masks information:')
            print(imgs_mask_train.shape)
            print(imgs_mask_train.dtype)
            hist,bins = np.histogram(imgs_mask_train)
            print(hist)
            print(bins)
    
        # Make the grayscale images RGB since that's what the model expects apparently
        if expandChannel:       
           imgs_input = np.stack((imgs_input,)*3, -1)
        else:
           imgs_input = np.expand_dims(imgs_input, 3)
        print('New shape of input images:')
        print(imgs_input.shape)
        if not do_prediction:
           imgs_mask_train = np.expand_dims(imgs_mask_train, 3)
           print('New shape of masks:')
           print(imgs_mask_train.shape)
    
        # Preprocess as per https://github.com/qubvel/segmentation_models
        preprocessing_fn = get_preprocessing(backbone)
        imgs_input = preprocessing_fn(imgs_input)
    
        # Return appropriate variables
        if not do_prediction:
            return(imgs_input,imgs_mask_train)
        else:
            return(imgs_input)

    # Import relevant modules and functions
    import sys
    sys.path.append(gParameters['segmentation_models_repo'])
    import numpy as np
    from keras.models import Model
    from keras.layers import Input, concatenate, Conv2D, MaxPooling2D, Conv2DTranspose, Dropout
    from keras.optimizers import Adam
    from keras.callbacks import ModelCheckpoint,ReduceLROnPlateau,EarlyStopping,CSVLogger
    from keras.layers.normalization import BatchNormalization
    from keras.backend import binary_crossentropy
    import keras
    import random
    import tensorflow as tf
    from keras.models import model_from_json
    from segmentation_models import Unet
    from segmentation_models.backbones import get_preprocessing
    K.set_image_data_format('channels_last')  # TF dimension ordering in this code
    
    # Basically constants
    expandChannel = True
    modelwtsfname = 'model_weights.h5'
    model_json_fname  = 'model.json'
    csvfname = 'model.csv'
    
    do_prediction = gParameters['predict']
    if not do_prediction: # Train...
        print('Training...')

        # Parameters
        inputnpyfname = gParameters['images']
        labels = gParameters['labels']
        initialize = gParameters['initialize']
        backbone = gParameters['backbone']
        encoder = gParameters['encoder']
        lr = float(gParameters['lr'])
        batch_size = gParameters['batch_size']
        obj_return = gParameters['obj_return']
        epochs = gParameters['epochs']

        # Preprocess the data
        imgs_train,imgs_mask_train = preprocess_data(do_prediction,inputnpyfname,labels,expandChannel,backbone)
        # Load, save, and compile the model
        model = Unet(backbone_name=backbone, encoder_weights=encoder)
        save_model_to_json(model,model_json_fname)
        model.compile(optimizer=Adam(lr=lr), loss='binary_crossentropy', metrics=['binary_crossentropy','mean_squared_error',dice_coef, dice_coef_batch, focal_loss()])
        # Load previous weights for restarting, if desired and possible
        if os.path.isfile(initialize):
            print('-'*30)
            print('Loading previous weights ...')
            model.load_weights(initialize)
        # Set up the training callback functions
        model_checkpoint = ModelCheckpoint(modelwtsfname, monitor=obj_return, save_best_only=True)
        reduce_lr = ReduceLROnPlateau(monitor=obj_return, factor=0.1,patience=100, min_lr=0.001,verbose=1)
        model_es = EarlyStopping(monitor=obj_return, min_delta=0.00000001, patience=100, verbose=1, mode='auto')
        csv_logger = CSVLogger(csvfname, append=True)
        # Train the model
        history_callback = model.fit(imgs_train, imgs_mask_train, batch_size=batch_size, epochs=epochs, verbose=2, shuffle=True, validation_split=0.10, callbacks=[model_checkpoint, reduce_lr, model_es, csv_logger])
        print("Minimum validation loss:")
        print(min(history_callback.history[obj_return]))
    else: # ...or predict
        print('Inferring...')

        # Parameters
        inputnpyfname = gParameters['images']
        initialize = gParameters['initialize']
        backbone = gParameters['backbone']
        # lr = float(gParameters['lr']) # this isn't needed but we're keeping it for the U-Net, where it is "needed"

        # Preprocess the data
        imgs_infer = preprocess_data(do_prediction,inputnpyfname,'',expandChannel,backbone)
        # Load the model
        #model = get_model(model_json_fname,initialize)
        model = get_model(os.path.dirname(initialize)+'/'+model_json_fname,initialize)
        
        # Run inference
        imgs_test_predict = model.predict(imgs_infer, batch_size=1, verbose=1)
        # Save the predicted masks
        np.save('mask_predictions.npy', np.squeeze(np.round(imgs_test_predict).astype('uint8')))
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