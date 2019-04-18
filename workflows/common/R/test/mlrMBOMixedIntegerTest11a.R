#library(devtools)
#load_all("../../../mlrMBO/")
#library(parallelMap)
#library(smoof)
#library(lhs)
#library(optparse)
set.seed(12345)
library(mlrMBO)
library(randomForest)

fun = function(x) {
  x = as.list(x)
  res = 0
  print(x)
  print(paste(x,sep=",",collapse=";"))
  r = as.numeric(x$batch_size)
  i = as.numeric(x$drop)
  res<-r+i

  if(x$model=="ae"){
    res<-res*1000
  }
  
  if(x$activation == "relu"){
    res<-res*1000
  }
  
  if(x$optimizer == "sgd"){
    res<-res*1000
  }

  if(x$optimizer == "sgd"){
    res<-res*1000
  }  
  
  if(as.numeric(x$reduce_lr)){
    res<-res*1000
  }
  
  return(res)
}

par.set = makeParamSet(
  # we optimize for ae and vae separately
  makeDiscreteParam("model", values=c("ae", "vae")),
  # latent_dim impacts ae more than vae
  #makeDiscreteParam("latent_dim", values=c(2, 8, 32, 128, 512)),
  makeIntegerParam("latent_dim", lower=1, upper=9, trafo = function(x) 2L^x),
  # use a subset of 978 landmark features only to speed up training
  makeDiscreteParam("use_landmark_genes", values=c(1)),
  # large batch_size only makes sense when warmup_lr is on
  # makeDiscreteParam("batch_size", values=c(32, 64, 128, 256, 512, 1024), 
  makeIntegerParam("batch_size", lower=5, upper=10, trafo = function(x) 2L^x),
  # use consecutive 978-neuron layers to facilitate residual connections
  makeDiscreteParam("dense", values=c("1500 500",
                                      "978 978",
                                      "978 978 978",
                                      "978 978 978 978",
                                      "978 978 978 978 978",
                                      "978 978 978 978 978 978")),
  makeIntegerParam("residual", lower=0, upper=1),
  makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),
  makeDiscreteParam("optimizer", values=c("adam", "sgd", "rmsprop")),
  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),
  makeIntegerParam("reduce_lr", lower=0, upper=1),
  makeIntegerParam("warmup_lr", lower=0, upper=1),
  makeNumericParam("drop", lower=0.1, upper=0.9),
  makeIntegerParam("epochs", lower=100, upper=200)
)

obj.fun = makeSingleObjectiveFunction(
  name = "mixed_integer_example",
  fn = fun,
  par.set = par.set,
  has.simple.signature = FALSE,
  minimize = TRUE
)

max.budget <- 1500
propose.points<-5

ctrl = makeMBOControl(n.objectives = 1, propose.points = propose.points, 
                      trafo.y.fun = makeMBOTrafoFunction('log', log),
                      impute.y.fun = function(x, y, opt.path, ...) .Machine$double.xmax )
ctrl = setMBOControlTermination(ctrl, max.evals = max.budget)
ctrl = setMBOControlInfill(ctrl, 
                           crit = makeMBOInfillCritCB(),
                           opt.restarts = 1, 
                           opt.focussearch.points = 1000)


design = generateDesign(n = max.budget, par.set = getParamSet(obj.fun))
design = head(design, n = propose.points)

configureMlr(show.info = FALSE, show.learner.output = FALSE, on.learner.warning = "quiet")
res = mbo(obj.fun, design = design, learner = NULL, control = ctrl, show.info = TRUE)

