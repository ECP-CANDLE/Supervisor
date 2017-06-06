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
        params = settings['parameters']
    except KeyError as e:
        print("Settings file (%s) does not contain key: %s" % (settingsFilename, str(e)))
        sys.exit(1)
    return(params)

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

params = loadSettings(settingsFilename)
values = {}
for i in range(1, len(params)+1):
    try:
         As = params[str(i)]
    except:
         print('Did not find parameter %i in settings file'%i)
         sys.exit(1)
    values[i] = As
results = expand(values, 1, len(params), [''])
result = ':'.join(results)

with open(paramsFilename, 'w') as the_file:
    the_file.write(result)

