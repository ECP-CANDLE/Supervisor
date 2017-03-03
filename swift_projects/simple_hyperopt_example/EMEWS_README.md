EMEWS project template
-----------------------

You have just created an EMEWS project. Consisting of the following
directories.

```
swift_project\
  data\
  ext\
  etc\
  python\
    test\
  R\
    test\
  scripts\
  swift\
  README.md
```
The directories are intended to contain the following:

 * `data` - model input etc. data
 * `etc` - additional code used by EMEWS
 * `ext` - swift-t extensions such as eqpy, eqr
 * `python` - python code (e.g. model exploration algorithms written in python)
 * `python\test` - tests of the python code
 * `R` - R code (e.g. model exploration algorithms written R)
 * `R\test` - tests of the R code
 * `scripts` - any necessary scripts (e.g. scripts to launch a model), excluding
    scripts used to run the workflow.
 * `swift` - swift code

Use the subtemplates to customize this structure for particular types of
workflows. These are: sweep, eqpy, and eqr.
