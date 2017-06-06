# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by
# the benchmark
param.set <- makeParamSet(
  makeIntegerParam("epochs", lower = 1, upper = 3),
  ## DEBUG PARAMETERS: DON'T USE THESE IN PRODUCTION RUN
  makeDiscreteParam("conv", values = c("32 20 16 32 10 1"))
)
