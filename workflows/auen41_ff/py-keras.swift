
import io;
import python;

r = python("import auen41_ff",
           "auen41_ff.go(\"%s\")" %
           "/home/wozniak/pb-data/auen-intel-tflow");
printf("result: %s", r);
