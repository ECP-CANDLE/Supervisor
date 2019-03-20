# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

param.set <- makeParamSet(

  # large batch_size only makes sense when warmup_lr is on
  #makeDiscreteParam("batch_size", values=c(32, 64, 128, 256, 512, 1024)),
  makeIntegerParam("batch_size", lower=9, upper=11, trafo = function(x) 2L^x),

  #makeDiscreteParam("residual", values=c(1, 0)),

  #makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),

  #makeDiscreteParam("optimizer", values=c("adam", "sgd", "rmsprop")),

  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),

  #makeDiscreteParam("reduce_lr", values=c(1, 0)),

  #makeDiscreteParam("warmup_lr", values=c(1, 0)),

  makeIntegerParam("epochs", lower=1, upper=1)
)
