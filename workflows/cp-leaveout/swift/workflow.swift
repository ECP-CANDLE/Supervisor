
/*
  CP LEAVEOUT SWIFT
  Main workflow
*/

import assert;
import files;
import io;
import python;
import unix;
import sys;
import string;
import location;
import math;

string FRAMEWORK = "keras";

string xcorr_root = getenv("XCORR_ROOT");
string preprocess_rnaseq = getenv("PREPROP_RNASEQ");
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

printf("TURBINE_OUTPUT: " + turbine_output);

string db_file = argv("db_file");
string cache_dir = argv("cache_dir");
string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

// string restart_number = argv("restart_number", "1");
string site = argv("site");

int cell_lines[] = [0:10];
int drugs[]      = [0:10];

string results[][];

app (file o) fake_uno(int leaveout_cell_line, int leaveout_drug)
{
  (emews_root/"swift/fake-uno.sh") leaveout_cell_line leaveout_drug o ;
}

foreach leaveout_cell_line in cell_lines
{
  foreach leaveout_drug in drugs
  {
    file f = fake_uno(leaveout_cell_line, leaveout_drug);
    results[leaveout_cell_line][leaveout_drug] = read(f);
  }
}
