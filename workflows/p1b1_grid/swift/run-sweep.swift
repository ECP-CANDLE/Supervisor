import string;
import files;
import io;
import sys;

// ===== Interface definitions for the three programs that we call ======
app (file f)
determineParameters(string settingsFilename)
{
  (getenv("APP_HOME")+"/determineParameters.sh") settingsFilename f;
}

app (file f)
evaluateOne(string params)
{
  (getenv("APP_HOME")+"/evaluateOne.sh") params f;
}

app ()
computeStats(string resultsFile)
{
  (getenv("APP_HOME")+"/computeStats.sh") resultsFile;
}


// ===== The program proper ==============================================
float results[string];

// Get parameters
settingsFilename = argv("settings");
printf(settingsFilename);
file parametersFile<"parameters.txt"> = determineParameters(settingsFilename);
parametersString = read(parametersFile);
parameters = split(parametersString, ":");

// Run experiments in parallel, passing each a different parameter set
foreach param in parameters
{
    file resultFile<"result-%s.txt"%param> = evaluateOne(param);
    results[param] = string2float(read(resultFile));
}

// Compute stats of this array of results
// Write directly to a file with write
file tmp = write(repr(results));

// Find the name of a file with filename
//trace("Temporary filename is: " + filename(tmp));

computeStats(filename(tmp));
