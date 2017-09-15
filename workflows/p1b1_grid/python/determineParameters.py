import sys, json, os

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
    return(epochs, batch_size, N1, NE, latent_dim, learning_rate)

def expand(Vs, fr, to, soFar):
    soFarNew = []
    for s in soFar:
        for v in Vs[fr]:
             if s == '':
                 soFarNew += [str(v)]
             else:
                 soFarNew += [s+','+str(v)]
    if fr==to:
        return(soFarNew)
    else:
        return expand(Vs, fr+1, to, soFarNew)

# ===== Main program ========================================================

if (len(sys.argv) < 3):
	print('requires arg1=settingsFilename and arg2=paramsFilename')
	sys.exit(1)

settingsFilename = sys.argv[1]
paramsFilename   = sys.argv[2]

epochs, batch_size, N1, NE, latent_dim, learning_rate = loadSettings(settingsFilename)

values = {1:epochs, 2: batch_size, 3: N1, 4: NE, 5: latent_dim, 6: learning_rate}
print values
results = expand(values, 1, len(values), [''])
result = ':'.join(results)

with open(paramsFilename, 'w') as the_file:
    the_file.write(result)

