
/*
   EMEWS EQPy.swift
*/

import location;
pragma worktypedef resident_work;

@dispatch=resident_work
(void v) _void_py(string code, string expr="\"\"") "turbine" "0.1.0"
    [ "turbine::python 1 1 <<code>> <<expr>> "];

@dispatch=resident_work
(string output) _string_py(string code, string expr) "turbine" "0.1.0"
    [ "set <<output>> [ turbine::python 1 1 <<code>> <<expr>> ]" ];

string init_package_string = "import eqpy\neqpy.init('%s')";

(void v) EQPy_init_package(location loc, string packageName){
    //printf("EQPy_init_package(%s) ...", packageName);
    string code = init_package_string % (packageName); //,packageName);
    //printf("Code is: \n%s", code);
    @location=loc _void_py(code) => v = propagate();
}

EQPy_stop(location loc){
    // do nothing
}

string get_string = "result = eqpy.output_q_get()";

(string result) EQPy_get(location loc){
    //printf("EQPy_get called");
    string code = get_string;
    //printf("Code is: \n%s", code);
    result = @location=loc _string_py(code, "result");
}

string put_string = """
eqpy.input_q.put("%s")\n""
""";

(void v) EQPy_put(location loc, string data){
    // printf("EQPy_put called with: \n%s", data);
    string code = put_string % data;
    // printf("EQPy_put code: \n%s", code);
    @location=loc _void_py(code) => v = propagate();
}

// Local Variables:
// c-basic-offset: 4
// End:
