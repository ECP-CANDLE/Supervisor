#library(devtools)
#load_all("../../../mlrMBO/")
#library(parallelMap)
#library(smoof)
#library(lhs)
#library(optparse)
set.seed(10000)
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
  makeDiscreteParam("activation", values = c("softmax", "elu", "softplus", "softsign", "relu", "tanh", "sigmoid", "hard_sigmoid", "linear")),
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
propose.points<-9
max.iterations<-5

ctrl = makeMBOControl(n.objectives = 1, propose.points = propose.points, 
                      trafo.y.fun = makeMBOTrafoFunction('log', log),
                      impute.y.fun = function(x, y, opt.path, ...) .Machine$double.xmax )
ctrl = setMBOControlTermination(ctrl, max.evals = max.budget, iters = max.iterations)
ctrl = setMBOControlInfill(ctrl, 
                           crit = makeMBOInfillCritCB(), 
                           opt.restarts = 1, 
                           opt.focussearch.points = 1000)

# d1 = generateGridDesign(par.set, trafo = TRUE)

design = generateDesign(n = max.budget, par.set = getParamSet(obj.fun))
design = head(design, n = propose.points)



# get the maximum number of variables
max_val_discrete = 0
index=0

for (v in par.set$pars) {
  if (v$type == "discrete"){
    index=index+1
    i = 0
    for (val in v$values){
      i=i+1
    }
    if (max_val_discrete < i){
      max_val_discrete = i
    }
  }
}

print(paste0("propose points=", propose.points, " Maximum discrete values=", max_val_discrete))
if (propose.points < max_val_discrete){
  print("Aborting! design.size is less than the discrete parameters specified")
  quit()
}



print(max_val_discrete)
params_names =getParamLengths(par.set)
mydesign = head(design, n = max_val_discrete)
i = 0
for (v in par.set$pars){
  i=i+1
  if (v$type == "discrete"){
    index=0
    for (val in v$values){
      index=index+1
      mydesign[[i]][index] = val
    }
  }
}

design=mydesign

surr.rf = makeLearner("regr.randomForest", 
                      predict.type = "se", 
                      fix.factors.prediction = TRUE,
                      se.method = "jackknife", 
                      se.boot = 8)



configureMlr(show.info = FALSE, show.learner.output = FALSE, on.learner.warning = "quiet")

#doesn't work, learner = surr.rf as above
res = mbo(obj.fun, design = design, learner = surr.rf, control = ctrl, show.info = TRUE)
#works (learner = NULL)
#res = mbo(obj.fun, design = design, learner = NULL, control = ctrl, show.info = TRUE)
