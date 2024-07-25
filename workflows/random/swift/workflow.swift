import string;
import files;
import io;
import sys;

string model_name     = getenv("MODEL_NAME");
string exp_id         = argv("exp_id");
string param_set_file = argv("param_set_file");

// ===== Interface definitions for the programs that we call ======
// Random values are created from bounds specified in data/settings.json file
app (file f)
determineParameters(string settingsFilename)
{
  (emews_root+"/swift/determineParameters.sh") settingsFilename f;
}

// This is where the p1b1 runner is called
app (file f)
evaluateOne(string params)
{
  (emews_root+"/swift/evaluateOne.sh") params f;
}

// call this to read all the resultsFiles and compute stats
app ()
computeStats(string resultsFile)
{
  (emews_root+"/swift/computeStats.sh") resultsFile;
}

// call this to create any required directories
app (void o) make_dir(string dirname)
{
  "mkdir" "-p" dirname;
}

printf("PYTHONPATH: %s", getenv("PYTHONPATH"));
printf("PYTHONHOME: %s", getenv("PYTHONHOME"));

// ===== The program proper ==============================================
string turbine_output = getenv("TURBINE_OUTPUT");
string emews_root     = getenv("EMEWS_PROJECT_ROOT");

//make the experiments dir
make_dir(turbine_output);

// Get parameters
settingsFilename = argv("settings");
sweepParamFile = turbine_output + "/sweep-file.txt";
file parametersFile<sweepParamFile> = determineParameters(param_set_file);
parametersString = read(parametersFile);
parameters = split(parametersString, ":");

// Run experiments in parallel, passing each a different parameter set
string results[];
foreach param,i in parameters
{
  run_id = "run_%03i" % i;
  results[i] =
    candle_model_train(param, exp_id, run_id, model_name);
}

// Compute stats of this array of results
// Write directly to a file with write
file tmp = write(repr(results));

// Find the name of a file with filename
//trace("Temporary filename is: " + filename(tmp));

computeStats(filename(tmp));
