import sys, json, os
import random 
import itertools

# ===== Definitions =========================================================
def expand(Vs, fr, to, soFar):
    soFarNew = []
    for s in soFar:
        if (Vs[fr] == None):
             print ("ERROR: The order of json inputs and values must be preserved")
             sys.exit(1)
        for v in Vs[fr]:
             if s == '':
                 soFarNew += [str(v)]
             else:
                 soFarNew += [s+','+str(v)]
    if fr==to:
        return(soFarNew)
    else:
        return expand(Vs, fr+1, to, soFarNew)

def generate_random(values, n_samples, benchmarkName):
    # select '#samples' random numbers between the range provided in settings.json file
    result = ""
    param_listed = []
    for s in range(n_samples):
        if(benchmarkName=="p1b1"):
            # values = {1:epochs, 2: batch_size, 3: N1, 4: NE}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            t_N1= random.randint(values[3][0], values[3][1])
            t_NE= random.randint(values[4][0], values[4][1])
            result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_N1) + ',' + str(t_NE) 
        elif(benchmarkName=="p1b3"):
            # values = {1:epochs, 2: batch_size, 3: test_cell_split, 4: drop}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            t_tcs= random.uniform(values[3][0], values[3][1])
            t_drop= random.uniform(values[4][0], values[4][1])
            result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_tcs) + ',' + str(t_drop) 
        elif(benchmarkName=="nt3"):
            # values = {1:epochs, 2: batch_size, 3: classes}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            t_classes= random.randint(values[3][0], values[3][1])
            result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_classes)  
        elif(benchmarkName=="p2b1"):
            # values = {1:epochs, 2: batch_size, 3: molecular_epochs, 4: weight_decay}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            t_me= random.randint(values[3][0], values[3][1])
            t_wd= random.uniform(values[4][0], values[4][1])
            result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_me) + ',' + str(t_wd) 
        elif(benchmarkName=="p3b1"):
            # values = {1:epochs, 2: batch_size}//, 3: learning_rate, 4: n_fold}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            result+=str(t_epoch) + ',' + str(t_batch_size)
        else:
            print('ERROR: Tried all possible benchmarks, Invalid benchmark name or json file')
            sys.exit(1)
        # Populate the result string for writing sweep-parameters file
        param_listed += [str(result)]
        result=""
    return (param_listed)

# ===== Main program ========================================================
if (len(sys.argv) < 3):
    print('requires arg1=settingsFilename and arg2=paramsFilename')
    sys.exit(1)

settingsFilename = sys.argv[1]
paramsFilename   = sys.argv[2]
benchmarkName    = sys.argv[3]
searchType       = sys.argv[4]

## Read in the variables from json file
#Trying to open the settings file
print("Reading settings: %s" % settingsFilename)
try:
    with open(settingsFilename) as fp:
        settings = json.load(fp)
except IOError as e:
    print("Could not open: %s" % settingsFilename)
    print("PWD is: '%s'" % os.getcwd())
    sys.exit(1)

# Register new variables for any benchmark here
#Common variables
epochs = settings.get('parameters').get('epochs')
batch_size = settings.get('parameters').get('batch_size')
# P1B1
N1 = settings.get('parameters').get('N1')
NE = settings.get('parameters').get('NE') 
#NT3
classes = settings.get('parameters').get('classes')   
#P2B1
molecular_epochs = settings.get('parameters').get('molecular_epochs') 
weight_decay = settings.get('parameters').get('weight_decay') 
#P3B1
# learning_rate = settings.get('parameters').get('learning_rate') 
# n_fold = settings.get('parameters').get('n_fold') 
#P1B3
test_cell_split = settings.get('parameters').get('test_cell_split') 
drop = settings.get('parameters').get('drop') 

# For random scheme determine number of samples
samples = settings.get('samples', {}).get('num', None)

## Done reading from file 

# Make values for computing grid sweep parameters
values = {}
if(benchmarkName=="p1b1"):
    values = {1:epochs, 2: batch_size, 3: N1, 4: NE}
elif(benchmarkName=="p1b3"):
    values = {1:epochs, 2: batch_size, 3: test_cell_split, 4: drop}
elif(benchmarkName=="nt3"):
    values = {1:epochs, 2: batch_size, 3: classes}
elif(benchmarkName=="p2b1"):
    values = {1:epochs, 2: batch_size, 3: molecular_epochs, 4: weight_decay}
elif(benchmarkName=="p3b1"):
    values = {1:epochs, 2: batch_size}
else:
    print('ERROR: Tried all possible benchmarks, Invalid benchmark name or json file')
    sys.exit(1)

# this (result) is : seperated string with all params
result = {}
# Determine parameter space based of search type
if(searchType == "grid"):
    results = expand(values, 1, len(values), [''])
elif(searchType =="random"):
    if(samples == None):
        print ("ERROR: Provide number of samples in json file")
        sys.exit(1)
    # result, results = generate_random(values, samples, benchmarkName) 
    results = generate_random(values, samples[0], benchmarkName) 
else:
    print ("ERROR: Invalid search type, specify either - grid or random")
    sys.exit(1)

counter=0
for a, b in itertools.combinations(results, 2):
    if(a == b):
        print ("Warning: skipping -identical parameters found", counter)
        results.remove(a)

#These are final : seperated parameters for evaluation
result = ':'.join(results)

with open(paramsFilename, 'w') as the_file:
    the_file.write(result)

