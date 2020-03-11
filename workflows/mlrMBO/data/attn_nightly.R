# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results


param.set <- makeParamSet(

  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),

  makeNumericParam("drop", lower=0, upper=0.9),
                    
  makeIntegerParam("epochs", lower=2, upper=3)
)


