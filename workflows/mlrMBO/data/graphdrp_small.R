
# NT3 Hyperparameter Search - Test 1
# These parameters should stay small for short tests
#       and use no dense parameters to avoid mlrMBO crashes

# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

param.set <- makeParamSet(
  makeDiscreteParam("test_batch", values = c(8, 16)),
  makeIntegerParam("epochs", lower = 1, upper = 2),
  # makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop", "adagrad", "adadelta")),
  # makeNumericParam("dropout", lower = 0, upper = 0.9),
  makeNumericParam("learning_rate", lower = 0.001, upper = 0.1)
)