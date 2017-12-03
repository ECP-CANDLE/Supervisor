# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark
# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results
param.set <- makeParamSet(
  makeDiscreteParam("cell_features", values=c("mirna", "expression")),
  # use a subset of 978 landmark features only to speed up training
  makeDiscreteParam("use_landmark_genes", values=c(1)),
  # use consecutive 1000-neuron layers to facilitate residual connections
  makeDiscreteParam("dense",
              values=c("1000",
                             "1000 1000",
                             "1000 1000 1000",
                             "1000 1000 1000 1000",
                             "1000 1000 1000 1000 1000")),
  makeDiscreteParam("dense_feature_layers",
              values=c("1000",
                             "1000 1000",
                             "1000 1000 1000",
                             "1000 1000 1000 1000",
                             "1000 1000 1000 1000 1000")),
  # large batch_size only makes sense when warmup_lr is on
  makeIntegerParam("batch_size", lower=5, upper=10, trafo = function(x) 2L^x),
  makeLogicalParam("residual"),
  makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),
  makeDiscreteParam("optimizer", values=c("adam", "sgd", "rmsprop")),
  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),
  makeLogicalParam("reduce_lr"),
  makeLogicalParam("warmup_lr"),
  makeIntegerParam("epochs", lower=5, upper=10),
  makeNumericParam("clipnorm", lower = 1e-04, upper = 1e01),
  makeNumericParam("clipvalue", lower = 1e-04, upper = 1e01),
  makeNumericParam("decay", lower = 0, upper = 1e01),
  makeDiscreteParam("epsilon", values = c(1e-6, 1e-8, 1e-10, 1e-12, 1e-14)),
  makeNumericParam("rho", lower = 1e-04, upper = 1e01),
  makeNumericParam("momentum", lower = 0, upper = 1e01),
  makeLogicalParam("nesterov"),
  makeNumericParam("beta_1", lower = 1e-04, upper = 1e01),
  makeNumericParam("beta_2", lower = 1e-04, upper = 1e01)
)



