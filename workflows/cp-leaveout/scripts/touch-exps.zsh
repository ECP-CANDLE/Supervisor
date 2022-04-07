#!/bin/zsh
set -eu

which python

A=( 750
    746
    757
    771
    743
    744
    759
    763
  )

{
  sw0
  print "START: " $( date-nice )
  print

  for X in $A
  do
    ds          experiments/X$X
    last-access experiments/X$X
    touch-all   experiments/X$X
    print
  done

  last-access ~/S/proj
  touch-all   ~/S/proj
  print

  last-access /gpfs/alpine/med106/scratch/wozniak/CANDLE-Data
  touch-all   /gpfs/alpine/med106/scratch/wozniak/CANDLE-Data

  print
  print "STOP:  " $( date-nice )
  sw1
} |& teeb touch-exps.out
