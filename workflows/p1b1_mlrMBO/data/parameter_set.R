# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark


param.set <- makeParamSet(
  makeDiscreteParam("batch_size", values = c(16,32,64,128,256, 512)),
  makeIntegerParam("epochs", lower = 5, upper = 50)
)
