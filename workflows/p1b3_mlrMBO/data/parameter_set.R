# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by
# the benchmark
param.set <- makeParamSet(
  makeIntegerParam("epochs", lower = 2, upper = 6),
  makeDiscreteParam("dense", values = c("1000 500 100 50")),

  ## DEBUG PARAMETERS: DON'T USE THESE IN PRODUCTION RUN
  makeIntegerParam("feature_subsample", lower=500, upper=500),
  makeIntegerParam("train_steps", lower=100, upper=100),
  makeIntegerParam("val_steps", lower=10, upper=10),
  makeIntegerParam("test_steps", lower=10, upper=10)
  ## END DEBUG PARAMS
)
