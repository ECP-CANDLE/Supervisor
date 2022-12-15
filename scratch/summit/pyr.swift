
import io;
import python;
import R;

result_python = python("print(\"PYTHON WORKS\")",
                       "repr(40+2)");
printf("result_python: %s", result_python);

result_R = R("print(\"R WORKS\")", "paste(40+2)");
printf("result_R: %s", result_R);
