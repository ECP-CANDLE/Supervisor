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
  makeDiscreteParam("model", values=c("ae")),

  # makeDiscreteParam("latent_dim", values=c(2, 8, 32, 128, 512)),
  makeIntegerParam("latent_dim", lower=1, upper=9, trafo = function(x) 2L^x),

  # use a subset of 978 landmark features only to speed up training
  makeDiscreteParam("use_landmark_genes", values=c(0)),



    # use consecutive 978-neuron layers to facilitate residual connections
#  makeDiscreteParam("dense", values=c("1500 500",
#                                      "978 978",
#                                      "978 978 978",
#                                      "978 978 978 978",
#                                      "978 978 978 978 978",
#                                      "978 978 978 978 978 978")),

  makeDiscreteParam("residual", values=c(1, 0)),

 makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),

  makeDiscreteParam("optimizer", values=c("adam", "sgd")),

  makeNumericParam("learning_rate", lower=0.00001, upper=0.1),

  makeDiscreteParam("reduce_lr", values=c(1, 0)),

  makeDiscreteParam("warmup_lr", values=c(1, 0)),

  makeNumericParam("drop", lower=0, upper=0.9),

  makeIntegerParam("epochs", lower=2, upper=3)
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

ptm <- proc.time()
# dummy objective function
simple.obj.fun = function(x){}

surr.rf = makeLearner("regr.randomForest",
                      predict.type = "se",
                      fix.factors.prediction = TRUE,
                      se.method = "jackknife",
                      se.boot = 8)



  itr <- 0
  max_itr <- round(max.budget/propose.points)

  configureMlr(show.info = FALSE, show.learner.output = TRUE, on.learner.warning = "quiet")
  time <-(proc.time() - ptm)
  res = mbo(obj.fun, design = design, learner = surr.rf, control = ctrl, show.info = TRUE)
  itr_res<-as.data.frame(res$opt.path)
  itr_res<-cbind(itr_res, stime = as.numeric(time[3]))
  all_res <-itr_res
  itr <- itr + 1
  par.set = getParamSet(obj.fun)
  par.set0<-par.set


  #iterative phase starts
  while (nrow(all_res) < max.budget){
    time <-(proc.time() - ptm)
    print(sprintf("nevals = %03d; itr = %03d; time = %5.5f;", nrow(all_res), itr, as.numeric(time[3])))
    min.index<-which(itr_res$y==min(itr_res$y))

    par.set.t = par.set0
    pars = par.set.t$pars
    lens = getParamLengths(par.set.t)
    k = sum(lens)
    pids = getParamIds(par.set.t, repeated = TRUE, with.nr = TRUE)

    snames = c("y", pids)
    reqDF = subset(itr_res, select = snames, drop =TRUE)
    bestDF <- reqDF[min.index,]
    print("reqDF")
    print(nrow(reqDF))
    print(summary(reqDF))

    print("itr-rf")
    train.model <- randomForest(log(y) ~ ., data=reqDF, ntree=10000, keep.forest=TRUE, importance=TRUE)
    var.imp <- importance(train.model, type = 1)
    #var.imp[which(var.imp[,1] < 0),1]<-0
    index <- sort(abs(var.imp[,1]),
                  decreasing = TRUE,
                  index.return = TRUE)$ix

    inputs <- rownames(var.imp)[index]
    scores <- var.imp[index,1]
    remove.index <- which(scores >= 0.9*max(scores))
    print(scores)
    rnames <- inputs[remove.index]
    print('removing:')
    print(rnames)


    par.set1<-par.set0
    pnames<-names(par.set$pars)
    print(par.set1)
    for (index in c(1:k)){
      p = pnames[index]
      type = par.set$pars[[index]]$type
      if(max(scores)>0){
        if (p %in% rnames){
          val  = subset(bestDF, select = p)
          cval = as.vector(unlist(val))
          print(p)
          print(cval)
          trafo <- par.set1$pars[[index]]$trafo
          if (type == "logical1"){
            par.set1$pars[[index]]<-makeLogicalParam(p, default = cval, tunable = FALSE,  trafo = trafo)
          } else if(type == "discrete") {
            par.set1$pars[[index]]<-makeDiscreteParam(p, values=c(cval),  trafo = trafo)
          } else {
            delta <- max(1, round(cval * 10/100))
            ll <- max(cval - delta, par.set$pars[[index]]$lower)
            uu <- min(cval + delta, par.set$pars[[index]]$upper)
            if(type == "integer") {
              if (par.set$pars[[index]]$lower == 0 | par.set$pars[[index]]$upper == 1){
                par.set1$pars[[index]]<-makeIntegerParam(p, lower=cval, upper=cval, trafo = trafo)
              } else {
                par.set1$pars[[index]]<-makeIntegerParam(p, lower=ll, upper=uu, trafo = trafo)
              }
            } else {
              par.set1$pars[[index]]<-makeNumericParam(p, lower=ll, upper=uu, trafo = trafo)
            }
          }
        }
      }
    }
    print('problem:')
    print(par.set1)

    #redefine objecitive function with par.set1
    obj.fun = makeSingleObjectiveFunction(
    name = "hyperparameter search",
    fn = simple.obj.fun,
    par.set = par.set1
    )

    #ctrl = setMBOControlTermination(ctrl, max.evals = propose.points)
    design = generateDesign(n = propose.points, par.set = par.set1)

    temp<-rbind(design,reqDF[,-1])
    design <- head(temp, n = propose.points)


    USE_MODEL <- TRUE
    if(USE_MODEL){
      yvals <- predict(train.model,design)
      design <- cbind(y=yvals, design)
      ctrl = setMBOControlTermination(ctrl, max.evals = 2*propose.points)
    } else {
      ctrl = setMBOControlTermination(ctrl, max.evals = propose.points)
    }
    print("mbo-itr")
    print(yvals)

    print(summary(yvals))
    res = mbo(obj.fun, design = design, learner = surr.rf, control = ctrl, show.info = FALSE)
    itr_res<-as.data.frame(res$opt.path)
    itr_res<-cbind(itr_res, stime = as.numeric(time[3]))
    itr_res<-tail(itr_res, n = propose.points)

    par.set0<-par.set1
    itr <- itr + 1
    print("bug msg:")
    print(names(all_res))
    print(names(itr_res))
    all_res <- rbind(all_res, itr_res)
  }

  return(all_res)
}
