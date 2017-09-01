emews_root <- Sys.getenv("EMEWS_PROJECT_ROOT")
if (emews_root == "") {
  r_root <- getwd()
} else {
  r_root <- paste0(emews_root, "/R")
}
wd <- getwd()
setwd(r_root)

source("mlrMBO_utils.R")

# EQ/R based parallel map
parallelMap2 <- function(fun, ...,
                         more.args = list(),
                         simplify = FALSE,
                         use.names = FALSE,
                         impute.error = NULL,
                         level = NA_character_,
                         show.info = NA){
  st = proc.time()

  #For wrapFun do this: initdesign
  if (deparse(substitute(fun)) == "wrapFun"){
    dots <- list(...)
    string_params <- elements_of_lists_to_json(dots[[1L]])
    # print(dots)
    # print(paste0("parallelMap2 called with list_param: ",string_params))
    # print(paste("parallelMap2 called with list size:", length(string_params)))
    OUT_put(string_params)
    string_results = IN_get()

    st = proc.time() - st

    # Assumes results are in the form a;b;c
    # Note: can also handle vector returns for each,
    # i.e., a,b;c,d;e,f
    res <- string_to_list_of_vectors(string_results)
    # using dummy time
    return(result_with_extras_if_exist(res,st[3]))
  }
  # For all other values of deparse(substitute(fun)) eg. proposePointsByInfillOptimization, doBaggingTrainIteration etc.
  else{
    return(pm(fun, ..., more.args = more.args, simplify = simplify, use.names = use.names, impute.error = impute.error,
       level = level, show.info = show.info))
  }
}

require(parallelMap)
require(jsonlite)

pm <- parallelMap

unlockBinding("parallelMap", as.environment("package:parallelMap"))
assignInNamespace("parallelMap", parallelMap2, ns="parallelMap", envir=as.environment("package:parallelMap"))
assign("parallelMap", parallelMap2, as.environment("package:parallelMap"))
lockBinding("parallelMap", as.environment("package:parallelMap"))

library(mlrMBO)

# dummy objective function
simple.obj.fun = function(x){}

# PRASANNA OBJECTIVE FUNCTION START
fun = function(x) {
  res = 0
  print(paste(x,sep=",",collapse=";"))
  r = x$batch_size
  i = x$drop
  res<-r*i
  #if (runif(1) > 1.1)
  #  res <- NaN
  #print(res)
  return(res)
}
objfun = makeSingleObjectiveFunction(
  name = "mixed_integer",
  fn = fun,
  par.set = makeParamSet(
    makeDiscreteParam("batch_size", values = c(16, 32, 64, 128, 256, 512)),
    makeIntegerParam("epochs", lower = 10, upper = 30),
    makeDiscreteParam("activation", values = c("softmax","elu","softplus","softsign",
                                               "relu", "tanh","sigmoid","hard_sigmoid",
                                               "linear" )),
    makeDiscreteParam("dense", values = c("500 100 50", "1000 500 100 50",
                                          "2000 1000 500 100 50")),
    makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop","adagrad",
                                              "adadelta","adamax","nadam")),
    makeNumericParam("drop", lower = 0, upper = 0.5),
    makeDiscreteParam("conv", values = c("50 50 50 50 50 1", "25 25 25 25 25 1",
                                         "10 10 1 5 5 1", "32 20 16 32 10 1"))
  ),
  has.simple.signature = FALSE,
  minimize = TRUE
)
# PRASANNA OBJECTIVE FUNCTION END

main_function <- function(max.budget = 110, max.iterations = 10,
                          design.size=10, propose.points=10,
                          restart="DISABLED") {
chkpntResults<-NULL
if (file.exists(restart)) {
  print(paste("Loading restart:", restart))
  nk<-100
  dummydf<-generateDesign(n = nk, par.set = getParamSet(objfun))
  pids <- names(dummydf)
  dummydf<-cbind("y"=1.0,dummydf)

  #rename first column and reorder
  res<-read.csv(restart)
  cnames<-names(res)
  cnames[1]<-"y"
  names(res)<-cnames
  print("ok1")
  print(names(res))
  print("d")
  print(names(dummydf))
  res<-subset(res, select=names(dummydf))
  print("ok2")
  res<-rbind(dummydf,res)
  res<-res[-c(1:nk),] # remove the dummy
  rownames(res)<-NULL
  chkpntResults<-res
} else if (restart == "DISABLED") {
  print("Not a restart.")
} else {
  print(paste0("Restart file not found: '", restart,"'"))
  quit()
}


  surr.rf = makeLearner("regr.randomForest", predict.type = "se",
                      fix.factors.prediction = TRUE,
                      se.method = "bootstrap", se.boot = 2, se.ntree = 10)
  ctrl = makeMBOControl(n.objectives = 1, propose.points = propose.points,
            impute.y.fun = function(x, y, opt.path, ...) .Machine$integer.max * 0.1 )
  ctrl = setMBOControlInfill(ctrl, crit = makeMBOInfillCritEI(se.threshold = 0.0),
                                 opt.restarts = 1, opt.focussearch.points = 1000)
  ctrl = setMBOControlTermination(ctrl, max.evals = max.budget, iters = max.iterations)

  if (is.null(chkpntResults)){
  #      design = generateDesign(n = 60, par.set = getParamSet(objfun))
     # design = generateDesign(n = design.size, par.set = getParamSet(obj.fun))

     print("assigning from dummy")
    design = generateDesign(n = 60, par.set = getParamSet(objfun))
  } else {
     # Generate design from restarts
     print("assigning from restart")
     design = chkpntResults
  }
  #   print(design)


  # FROM BEFORE RESTARTS: design = generateDesign(n = design.size, par.set = getParamSet(obj.fun))
  #  print(paste("design:", design))
  configureMlr(show.info = FALSE, show.learner.output = FALSE, on.learner.warning = "quiet")
  res = mbo(objfun, design = design, learner = surr.rf, control = ctrl, show.info = TRUE)

  return(res)
}

# ask for parameters from queue
OUT_put("Params")
# accepts arguments to main_function, e.g., "pp = 2, it = 5"
res <- IN_get()

print(paste0("Params from Swift:", res))

l <- eval(parse(text = paste0("list(",res,")")))
# print(l)
# source(l$param.set.file)

# dummy objective function, only par.set is used
# and param.set is sourced from param.set.file
# obj.fun = makeSingleObjectiveFunction(
#   name = "hyperparameter search",
#   fn = simple.obj.fun,
#   par.set = param.set
# )

# remove this as its not an arg to the function
l$param.set.file <- NULL

final_res <- do.call(main_function,l)
OUT_put("DONE")

turbine_output <- Sys.getenv("TURBINE_OUTPUT")
if (turbine_output != "") {
  setwd(turbine_output)
}
# This will be saved to experiment directory
saveRDS(final_res,file = "final_res.Rds")

setwd(wd)
OUT_put("Look at final_res.Rds for final results.")
print("algorithm done.")
