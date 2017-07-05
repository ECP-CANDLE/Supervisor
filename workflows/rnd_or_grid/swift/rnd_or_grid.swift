import string;
import files;
import io;
import sys;

// ===== Interface definitions for the programs that we call ======
// Random values are created from bounds specified in data/settings.json file
app (file f)
determineParameters(string settingsFilename, string benchmark, string searchType)
{
  (getenv("APP_HOME")+"/determineParameters.sh") settingsFilename f benchmark searchType;
}

// This is where the p1b1 runner is called
app (file f)
evaluateOne(string params, string benchmark)
{
  (getenv("APP_HOME")+"/evaluateOne.sh") params f benchmark;
}

// call this to read all the resultsFiles and compute stats
app ()
computeStats(string resultsFile)
{
  (getenv("APP_HOME")+"/computeStats.sh") resultsFile;
}

// call this to create any required directories
app (void o) make_dir(string dirname) {
  "mkdir" "-p" dirname;
}


// ===== The program proper ==============================================
string turbine_output = getenv("TURBINE_OUTPUT");
string app_home = getenv("APP_HOME");
float results[string];

//make the experiments dir
make_dir(turbine_output);

// Get parameters
benchmark = argv("benchmark_name");
searchType = argv("search_type");
settingsFilename = app_home+"/../data/"+benchmark+"_settings.json";
string sweepParamFile = turbine_output+"/sweep-parameters.txt";
file parametersFile<sweepParamFile> = determineParameters(settingsFilename, benchmark, searchType);
parametersString = read(parametersFile);
parameters = split(parametersString, ":");

// Run experiments in parallel, passing each a different parameter set
foreach param in parameters
{
	string rName = turbine_output+"/result-"+param+".txt";
    file resultFile<rName> = evaluateOne(param, benchmark);
    results[param] = string2float(read(resultFile));
}

// Compute stats of this array of results
// Write directly to a file with write
file tmp = write(repr(results));
computeStats(filename(tmp));

