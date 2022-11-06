# If it's defined in the environment, append $SUPP_PYTHONPATH to the Python path
import json
import os

supp_pythonpath = os.getenv("SUPP_PYTHONPATH")
if supp_pythonpath is not None:
    import sys

    sys.path.append(supp_pythonpath)


# Load the hyperparameter dictionary stored in the JSON file params.json
def load_params(params_json_file):
    with open(params_json_file) as infile:
        return json.load(infile)


# Write the history.history dictionary to a JSON file
def write_history(history, val_to_return_json_file):
    with open(val_to_return_json_file, "w") as outfile:
        json.dump(history.history, outfile)


# Make a history.history dictionary from a return value and write it to a JSON file
def write_history_from_value(
    val_to_return, val_to_return_json_file
):  # val_to_return_json_file should be val_to_return.json to match the value in candle_compliant_wrapper.py
    with open(val_to_return_json_file, "w") as outfile:
        json.dump(
            {
                "val_loss": [val_to_return],
                "val_corr": [val_to_return],
                "val_dice_coef": [val_to_return],
            },
            outfile,
        )
