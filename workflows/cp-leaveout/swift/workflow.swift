
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
// string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

// string restart_number = argv("restart_number", "1");
string site = argv("site");

int N = 4; // The divisor of the leave out rows/columns

int X[] = [0:0];
int Y[] = [0:N];

string results[][];

app (file o) fake_uno(int leaveout_cell_line, int leaveout_drug)
{
  (emews_root/"swift/fake-uno.sh") leaveout_cell_line leaveout_drug o ;
}

app (file o) fake_nt3(int leaveout_punch_x, int leaveout_punch_y)
{
  (emews_root/"swift/fake-nt3.sh") leaveout_punch_x leaveout_punch_y o ;
}

foreach punch_x in X
{
  foreach punch_y in Y
  {
    file f = fake_nt3(punch_x, punch_y);
    results[punch_x][punch_y] = read(f);
  }
}

// The test*.sh scripts check for "RESULTS:"
printf("RESULTS: %i", size(results));
