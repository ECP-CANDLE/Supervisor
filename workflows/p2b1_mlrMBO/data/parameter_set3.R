# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by
# the benchmark
param.set <- makeParamSet(
  makeDiscreteParam("batch_size", values = c(32, 64, 128)),
  makeIntegerParam("epochs", lower = 1, upper = 3)
)
