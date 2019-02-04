
# NT3 Hyperparameter Search - Test 1
# These parameters should stay small for short tests
#       and use no dense parameters to avoid mlrMBO crashes

# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

param.set <- makeParamSet(
#  makeDiscreteParam("batch_size", values = c(16, 32, 64, 128, 256, 512)),
  makeDiscreteParam("batch_size", values = c(16, 32, 64)),
  makeIntegerParam("epochs", lower = 2, upper = 5),
#  makeDiscreteParam("activation", values = c("softmax", "elu", "softplus", "softsign", "relu", "tanh", "sigmoid", "hard_sigmoid", "linear")),
#  makeDiscreteParam("dense", values = c("500 100 50", "1000 500 100 50", "2000 1000 500 100 50", "2000 1000 1000 500 100 50", "2000 1000 1000 1000 500 100 50")),
#  makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop", "adagrad", "adadelta")),
  makeNumericParam("drop", lower = 0, upper = 0.9),
  makeNumericParam("learning_rate", lower = 0.00001, upper = 0.1),
  makeDiscreteParam("conv", values = c("50 50 50 50 50 1", "25 25 25 25 25 1", "64 32 16 32 64 1", "100 100 100 100 100 1", "32 20 16 32 10 1"))
  ## DEBUG PARAMETERS: DON'T USE THESE IN PRODUCTION RUN
  ## makeDiscreteParam("conv", values = c("32 20 16 32 10 1"))
)
