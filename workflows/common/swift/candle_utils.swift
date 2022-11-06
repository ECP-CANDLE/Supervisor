
/** CANDLE UTILS SWIFT */

/** report_env(): report the environment via Tcl */
report_env() "turbine" "1.0"
[
----
puts ""
puts "report_env() ..."
puts ""
global env
# puts [ array names env ]
puts "TURBINE_HOME: $env(TURBINE_HOME)"
puts ""
set tokens [ split $env(PATH) ":" ]
foreach token $tokens {
  puts "PATH: $token"
}
puts ""
set tokens [ split $env(LD_LIBRARY_PATH) ":" ]
foreach token $tokens {
  puts "LLP: $token"
}
if [ info exists env(PYTHONHOME) ] {
  puts ""
  puts "PYTHONHOME: $env(PYTHONHOME)"
}
if [ info exists env(PYTHONPATH) ] {
  puts ""
  set tokens [ split $env(PYTHONPATH) ":" ]
  foreach token $tokens {
    puts "PYTHONPATH: $token"
  }
}
puts ""
set pythons [ exec which python python3 ]
foreach p $pythons {
  puts "PYTHON: $p"
}
puts ""
puts "report_env() done."
puts ""
----
];
