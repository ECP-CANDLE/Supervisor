# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results
param.set <- makeParamSet(
  # we optimize for ae and vae separately
  makeDiscreteParam("model", values=c("ae", "vae")),
  # latent_dim impacts ae more than vae
  makeDiscreteParam("latent_dim", values=c(2, 8, 32, 128, 512)),
  # use a subset of 978 landmark features only to speed up training
  makeDiscreteParam("use_landmark_genes", values=c(1)),
  # large batch_size only makes sense when warmup_lr is on
  makeDiscreteParam("batch_size", values=c(32, 64, 128, 256, 512, 1024)),
  # use consecutive 978-neuron layers to facilitate residual connections
  makeDiscreteParam("dense", values=c("1500 500",
                                      "978 978",
              "978 978 978",
              "978 978 978 978",
              "978 978 978 978 978",
              "978 978 978 978 978 978")),
  makeDiscreteParam("residual", values=c(1, 0)),
  makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),
  makeDiscreteParam("optimizer", values=c("adam", "sgd", "rmsprop")),
  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),
  makeDiscreteParam("reduce_lr", values=c(1, 0)),
  makeDiscreteParam("warmup_lr", values=c(1, 0)),
  makeNumericParam("drop", lower=0, upper=0.9),
  makeIntegerParam("epochs", lower=100, upper=200),
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
