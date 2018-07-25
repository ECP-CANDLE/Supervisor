# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark

# Current best val_corr: 0.96 for ae, 0.86 for vae
# We are more interested in vae results


param.set <- makeParamSet(
  
  makeDiscreteParam("cell_features", values=c("expression")),

  # use a subset of 978 landmark features only to speed up training
  makeDiscreteParam("use_landmark_genes", values=c(1)),

  makeDiscreteParam("residual", values=c(1, 0)),
                  
                  
  makeDiscreteParam("reduce_lr", values=c(1, 0)),
                    
  makeDiscreteParam("warmup_lr", values=c(1, 0)),
                                     
  makeIntegerParam("epochs", lower=1, upper=3)
)



