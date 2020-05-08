param.set <- makeParamSet(
  makeIntegerParam("epochs", lower = 2, upper = 2),
  makeNumericParam("dropout", lower = 0.1, upper = 0.2),
  makeNumericParam("learning_rate", lower = 0.00001, upper = 0.001)
  ## makeDiscreteParam("conv", values = c("32 20 16 32 10 1"))
)

