# NT3 Hyperparameter Search - Test 1
# These parameters should stay small for short tests

# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

param.set <- makeParamSet(
  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),
  #makeNumericParam("learning_rate", lower = 0.00001, upper = 1.0),
#  makeDiscreteParam("batch_size", values = c( 16, 32, 48, 64, 80, 96, 112, 128 )),
  makeIntegerParam("epochs", lower = 5, upper = 50),
  makeNumericParam("dropout", lower = 0.0, upper = 0.9),
#  makeDiscreteParam("optimizer", values = c( 'adam', 'adadelta', 'sgd', 'rmsprop' )),
  makeIntegerParam("filter_sizes", lower = 1, upper = 10),
  makeIntegerParam("filter_sets", lower = 1, upper = 5),
  makeIntegerParam('wv_len', lower = 5, upper = 300),
  makeIntegerParam("num_filters", lower = 5, upper = 200),
  makeNumericParam("emb_l2", lower = 0.000001, upper = 0.1),
  makeNumericParam("w_l2", lower = 0.000001, upper = 0.1)
)
