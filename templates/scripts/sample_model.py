# Find and load the wrapper_connector module in order to, here, get the load_params() function that reads in the JSON file holding the current set of hyerparameters
import sys, os
sys.path.append(os.getenv("CANDLE")+'/Supervisor/templates/scripts')
import wrapper_connector
gParameters = wrapper_connector.load_params('params.json')
################ ADD MODEL BELOW USING gParameters DICTIONARY AS CURRENT HYPERPARAMETER SET ###############################################################


import scanpy

print(gParameters)
print(type(gParameters))

val_to_return = 4.7


################ ADD MODEL ABOVE USING gParameters DICTIONARY AS CURRENT HYPERPARAMETER SET ###############################################################
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