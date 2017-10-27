# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results


param.set <- makeParamSet(
 
 makeDiscreteParam("cell_features", values=c("mirna","expression")),

 # use a subset of 978 landmark features only to speed up training
 makeDiscreteParam("use_landmark_genes", values=c(1)),
 
 # use consecutive 1000-neuron layers to facilitate residual connections
 makeDiscreteParam("dense",
             values=c(      "1000 1000",
                            "1000 1000 1000")),

 makeDiscreteParam("dense_feature_layers",
             values=c(      "1000 1000",
                            "1000 1000 1000")),

 # large batch_size only makes sense when warmup_lr is on
 #makeDiscreteParam("batch_size", values=c(32, 64, 128, 256, 512, 1024)),
 makeIntegerParam("batch_size", lower=5, upper=10, trafo = function(x) 2L^x),

 makeNumericParam("learning_rate", lower=0.00001, upper=0.1),
                   
 makeIntegerParam("epochs", lower=25, upper=26)
)
