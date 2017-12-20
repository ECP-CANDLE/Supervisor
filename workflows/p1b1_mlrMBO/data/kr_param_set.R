# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results

param.set <- makeParamSet(
 
  #  # latent_dim impacts ae more than vae
  # makeDiscreteParam("latent_dim", values=c(2, 8, 32, 64, 132)),


  # large batch_size only makes sense when warmup_lr is on
  # makeDiscreteParam("batch_size", values=c(2, 16, 32, 64, 128)),

  # makeDiscreteParam("batch_size", values=c(16)),

  # use consecutive 978-neuron layers to facilitate residual connections
  # makeDiscreteParam("dense", values=c("1400 600",
  #                                     "1500 500",
  #             "1500 400",
  #             "1400 450",
  #             "1450 500",
  #             "1500 600")),

  # makeDiscreteParam("residual", values=c(1, 0)),

  # makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),

  # makeDiscreteParam("optimizer", values=c("adam", "sgd")),
  # latent_dim impacts ae more than vae
  makeIntegerParam("latent_dim", lower=2, upper=64),
  makeIntegerParam("batch_size", lower=30, upper=40),
  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),

  # makeDiscreteParam("reduce_lr", values=c(1, 0)),

  # makeDiscreteParam("warmup_lr", values=c(1, 0)),

  # makeNumericParam("drop", lower=0, upper=0.9),
  makeIntegerParam("epochs", lower=4, upper=8)
)

