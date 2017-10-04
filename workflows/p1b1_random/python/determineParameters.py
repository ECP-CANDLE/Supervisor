import sys, json, os
from random import randint, uniform

# ===== Definitions =========================================================

def loadSettings(settingsFilename):
    print("Reading settings: %s" % settingsFilename)
    try:
        with open(settingsFilename) as fp:
            settings = json.load(fp)
    except IOError as e:
        print("Could not open: %s" % settingsFilename)
        print("PWD is: '%s'" % os.getcwd())
        sys.exit(1)
    try:
        epochs = settings['parameters']["epochs"]
        batch_size = settings['parameters']["batch_size"]
        N1 = settings['parameters']["N1"]
        NE = settings['parameters']["NE"]        
        latent_dim = settings['parameters']["latent_dim"]        
        learning_rate = settings['parameters']["learning_rate"]        


    except KeyError as e:
        print("Settings file (%s) does not contain key: %s" % (settingsFilename, str(e)))
        sys.exit(1)
    try:
        samples = settings['samples']["num"]
    except KeyError as e:
        print("Settings file (%s) does not contain key: %s" % (settingsFilename, str(e)))
        sys.exit(1)
    return(epochs, batch_size, N1, NE, latent_dim, learning_rate, samples)

# ===== Main program ========================================================

if (len(sys.argv) < 3):
	print('requires arg1=settingsFilename and arg2=paramsFilename')
	sys.exit(1)

settingsFilename = sys.argv[1]
paramsFilename   = sys.argv[2]

print (settingsFilename)
print (paramsFilename)

epochs, batch_size, N1, NE, latent_dim, learning_rate, samples = loadSettings(settingsFilename)
result=""

# select '#samples' random numbers between the range provided in settings.json file
for s in range(samples[0]):
    t_epoch= randint(epochs[0], epochs[1])
    t_batch_size= randint(batch_size[0], batch_size[1])
    t_N1= randint(N1[0], N1[1])
    t_NE= randint(NE[0], NE[1])
    t_ld= randint(latent_dim[0], latent_dim[1])
    t_lr= uniform(learning_rate[0], learning_rate[1])
    result+=str(t_epoch) + ',' + str(t_batch_size) + ',' + str(t_N1) + ',' + str(t_NE) + ',' + str(t_ld)+ ',' + str(t_lr) 
    if(s < (samples[0]-1)):
        result+=":"

with open(paramsFilename, 'w') as the_file:
    the_file.write(result)

