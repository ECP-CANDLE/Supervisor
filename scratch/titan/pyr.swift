
import io;
import python;
import R;

i = python("print(\"python works\")",
           "repr(2+2)");
printf("i: %s", i);

printf(R("", "\"R STRING OK\""));
