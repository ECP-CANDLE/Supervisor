# This file should generally follow the standard CANDLE-compliance procedure

def initialize_parameters():

    # Add the candle_keras library to the Python path
    import sys, os
    sys.path.append(os.getenv("CANDLE")+'/Candle/common')

    # Instantiate the Benchmark class (the values of the prog and desc parameters don't really matter)
    import candle_keras as candle
    mymodel_common = candle.Benchmark(os.path.dirname(os.path.realpath(__file__)), os.getenv("DEFAULT_PARAMS_FILE"), 'keras', prog='myprogram', desc='My CANDLE example')

    # Read the parameters (in a dictionary format) pointed to by the environment variable DEFAULT_PARAMS_FILE
    gParameters = candle.initialize_parameters(mymodel_common)

    # Return this dictionary of parameters
    return(gParameters)

def run(gParameters):

    # Define the dummy history class; defining it here to keep this file aligned with the standard CANDLE-compliance procedure
    class HistoryDummy:
        def __init__(self, mynum):
            self.history = {'val_loss': [mynum], 'val_corr': [mynum], 'val_dice_coef': [mynum]}

    # Reformat a value that doesn't have an analogous field in the JSON format
    gParameters['datatype'] = str(gParameters['datatype'])

    # Write the current set of hyperparameters to a JSON file
    import json
    with open('params.json', 'w') as outfile:
        json.dump(gParameters, outfile)

    # Run the wrapper script model_wrapper.sh where the environment is defined and the model (whether in Python or R) is called
    myfile = open('subprocess_out_and_err.txt','w')
    import subprocess, os
    print('Starting run of model_wrapper.sh from candle_compliant_wrapper.py...')
    subprocess.run(['bash', os.getenv("CANDLE")+'/Supervisor/templates/scripts/model_wrapper.sh'], stdout=myfile, stderr=subprocess.STDOUT)
    print('Finished run of model_wrapper.sh from candle_compliant_wrapper.py')
    myfile.close()

    # Read in the history.history dictionary containing the result from the JSON file created by the model
    history = HistoryDummy(4444)
    import json
    with open('val_to_return.json') as infile:
        history.history = json.load(infile)
    return(history)
    
def main():
    gParameters = initialize_parameters()
    run(gParameters)

if __name__ == '__main__':
    main()
    try:
        from keras import backend as K
        K.clear_session()
    except AttributeError:
        pass