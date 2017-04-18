# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
param.set <- makeParamSet(
  makeIntegerParam("epoch", lower = 2, upper = 6)
)
