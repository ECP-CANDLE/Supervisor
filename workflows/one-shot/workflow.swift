
/** WORKFLOW SWIFT */

import io;
import sys;

printf("WORKFLOW PWD: " + getenv("PWD"));

string run_nt3 = getenv("THIS") / "run-nt3.sh";

app nt3()
{
  run_nt3 ;
}

nt3();
