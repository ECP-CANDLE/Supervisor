import python;
import io;

string template =
"""
import math

a = math.sin(%f)
""";

printf(template % 1.5);
i = python(template % 1.5, "str(a)");
printf("answer: %s", i);
