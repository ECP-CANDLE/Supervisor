
import io;
import python;
import sys;

data_directory = argv("data-directory");

r = python("import auen41_ff",
           "auen41_ff.go(\"%s\")" %
           data_directory);
printf("result: %s", r);
