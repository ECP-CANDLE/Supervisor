import string;
import files;
import io;
import sys;

// ===== Interface definitions for the programs that we call ======
// Random values are created from bounds specified in data/settings.json file
app (file f)
determineParameters(string settingsFilename)
{
  (getenv("EMEwS_ROOT_DIR")+"/swift/determineParameters.sh") settingsFilename f;
}

// This is where the p1b1 runner is called
app (file f)
evaluateOne(string params)
{
  (getenv("EMEWS_PROJECT_ROOT")+"/swift/evaluateOne.sh") params f;
}

// call this to read all the resultsFiles and compute stats
app ()
computeStats(string resultsFile)
{
  (getenv("EMEWS_PROJECT_ROOT")+"/swift/computeStats.sh") resultsFile;
}

// call this to create any required directories
app (void o) make_dir(string dirname) {
  "mkdir" "-p" dirname;
}


printf("PYTHONPATH: %s", getenv("PYTHONPATH"));
printf("PYTHONHOME: %s", getenv("PYTHONHOME"));

// ===== The program proper ==============================================
string turbine_output = getenv("TURBINE_OUTPUT");
float results[string];

//make the experiments dir
make_dir(turbine_output);

// Get parameters
settingsFilename = argv("settings");
string sweepParamFile = turbine_output+"/sweep-parameters.txt";
file parametersFile<sweepParamFile> = determineParameters(settingsFilename);
parametersString = read(parametersFile);
parameters = split(parametersString, ":");

// Run experiments in parallel, passing each a different parameter set
foreach param in parameters
{
	string rName = turbine_output+"/result-"+param+".txt";
	printf(rName);
    file resultFile<rName> = evaluateOne(param);
    results[param] = string2float(read(resultFile));
}

// Compute stats of this array of results
// Write directly to a file with write
file tmp = write(repr(results));

// Find the name of a file with filename
//trace("Temporary filename is: " + filename(tmp));

computeStats(filename(tmp));
