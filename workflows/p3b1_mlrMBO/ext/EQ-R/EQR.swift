(void v) EQR_init_script(location L, string filename)
{
  v = @location=L EQR_tcl_initR(filename);
}

(void v) EQR_stop(location L)
{
  v = @location=L EQR_tcl_stop();
}

EQR_delete_R(location L)
{
  @location=L EQR_tcl_delete_R();
}

(string result) EQR_get(location L)
{
  result = @location=L EQR_tcl_get();
}


(void v) EQR_put(location L, string data)
{
  v = @location=L EQR_tcl_put(data);
}

(boolean b) EQR_is_initialized(location L) {
  b = @location=L EQR_tcl_is_initialized();
}

pragma worktypedef resident_work;


@dispatch=resident_work
(void v) EQR_tcl_initR(string filename)
"eqr" "0.1"
[ "initR <<filename>>" ];

@dispatch=resident_work
(void v) EQR_tcl_stop()
"eqr" "0.1"
[ "stopIt" ];

@dispatch=resident_work
EQR_tcl_delete_R()
"eqr" "0.1"
[ "deleteR" ];


@dispatch=resident_work
(string result) EQR_tcl_get()
"eqr" "0.1"
[ "set <<result>> [ OUT_get ]" ];

@dispatch=resident_work
(void v)
EQR_tcl_put(string data)
"eqr" "0.1"
[ "IN_put <<data>>" ];

@dispatch=resident_work
(boolean result) EQR_tcl_is_initialized()
"eqr" "0.1"
[ "set <<result>> [ EQR_is_initialized ]" ];
