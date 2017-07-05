import sys, json, os
import random 

# ===== Definitions =========================================================
def expand(Vs, fr, to, soFar):
    soFarNew = []
    for s in soFar:
        print Vs[fr]
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
    for s in range(samples[0]):
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
            # values = {1:epochs, 2: batch_size, 3: shared_nnet_spec, 4: n_fold}
            t_epoch= random.randint(values[1][0], values[1][1])
            t_batch_size= random.randint(values[2][0], values[2][1])
            t_sns= random.randint(values[3][0], values[3][1])
            t_nf= random.randint(values[4][0], values[4][1])
            result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_sns) + ',' + str(t_nf) 
        else:
            print('ERROR: Tried all possible benchmarks, Invalid benchmark name or json file')
            sys.exit(1)
        # Populate the result string for writing sweep-parameters file
        if(s < (samples[0]-1)):
            result+=":"
    return result

# ===== Main program ========================================================
if (len(sys.argv) < 3):
    print('requires arg1=settingsFilename and arg2=paramsFilename')
    sys.exit(1)

settingsFilename = sys.argv[1]
paramsFilename   = sys.argv[2]
benchmarkName    = sys.argv[3]
searchType       = sys.argv[4]

#Trying to open the settings file
print("Reading settings: %s" % settingsFilename)
try:
    with open(settingsFilename) as fp:
        settings = json.load(fp)
except IOError as e:
    print("Could not open: %s" % settingsFilename)
    print("PWD is: '%s'" % os.getcwd())
    sys.exit(1)

# Read in the variables from json file
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
shared_nnet_spec = settings.get('parameters').get('shared_nnet_spec') 
n_fold = settings.get('parameters').get('n_fold') 
#P1B3
test_cell_split = settings.get('parameters').get('test_cell_split') 
drop = settings.get('parameters').get('drop') 

# For random scheme determine number of samples
samples = settings.get('samples', {}).get('num', None)


# Make values for computing grid sweep parameters
values = {}
if(benchmarkName=="p1b1"):
    values = {1:epochs, 2: batch_size, 3: N1, 4: NE}
    print values
elif(benchmarkName=="p1b3"):
    values = {1:epochs, 2: batch_size, 3: test_cell_split, 4: drop}
    print values
elif(benchmarkName=="nt3"):
    values = {1:epochs, 2: batch_size, 3: classes}
    print values
elif(benchmarkName=="p2b1"):
    values = {1:epochs, 2: batch_size, 3: molecular_epochs, 4: weight_decay}
    print values
elif(benchmarkName=="p3b1"):
    values = {1:epochs, 2: batch_size, 3: shared_nnet_spec, 4: n_fold}
    print values
else:
    print('ERROR: Tried all possible benchmarks, Invalid benchmark name or json file')
    sys.exit(1)

result = {}
if(searchType == "grid"):
    results = expand(values, 1, len(values), [''])
    result = ':'.join(results)
elif(searchType =="random"):
    if(samples == None):
        print ("ERROR: Provide number of samples in json file")
        sys.exit(1)
    result = generate_random(values, samples, benchmarkName) 
else:
    print ("ERROR: Invalid search type, specify either - grid or random")
    sys.exit(1)


with open(paramsFilename, 'w') as the_file:
    the_file.write(result)

