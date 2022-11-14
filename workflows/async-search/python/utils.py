import csv
import json
import math
import os
import re
import subprocess
import sys
import time
from string import Template


def saveResults(resultsList, json_fname, csv_fname):
    print(resultsList)
    print(json.dumps(resultsList, indent=4, sort_keys=True))
    with open(json_fname, "w") as outfile:
        json.dump(resultsList, outfile, indent=4, sort_keys=True)

    keys = resultsList[0].keys()
    with open(csv_fname, "w") as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(resultsList)
