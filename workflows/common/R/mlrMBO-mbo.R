  set.seed(12345)

  # mlrMBO EMEWS Algorithm Wrapper

  emews_root <- Sys.getenv("EMEWS_PROJECT_ROOT")
  if (emews_root == "") {
    r_root <- getwd()
  } else {
    r_root <- paste0(emews_root, "/../common/R")
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

  main_function <- function(max.budget = 110,
                            max.iterations = 10,
                            design.size=10,
                            propose.points=10,
                            restart.file,
                            hpo.id = 1) {

    assign("hpo.id", hpo.id, envir = .GlobalEnv)
    print("Using randomForest")
    surr.rf = makeLearner("regr.randomForest", 
                      predict.type = "se", 
                      fix.factors.prediction = TRUE)
    ctrl = makeMBOControl(n.objectives = 1, 
                          propose.points = propose.points,
			  impute.y.fun = function(x, y, opt.path, ...) .Machine$double.xmax,
			  trafo.y.fun = makeMBOTrafoFunction('log', log))
    ctrl = setMBOControlInfill(ctrl, 
                               crit = makeMBOInfillCritCB(),
                               opt.restarts = 1, 
                               opt.focussearch.points = 1000)
    ctrl = setMBOControlTermination(ctrl, 
                                    max.evals = max.budget, 
                                    iters = max.iterations)

    chkpntResults<-NULL
    # TODO: Make this an argument
    restartFile<-restart.file 
    if (file.exists(restart.file)) {
      print(paste("Loading restart:", restart.file))

      nk<-100
      dummydf<-generateDesign(n = nk, par.set = getParamSet(obj.fun))
      pids <- names(dummydf)
      dummydf<-cbind("y"=1.0,dummydf)

      #rename first column and reorder
      res<-read.csv(restart.file)
      cnames<-names(res)
      names(res)<-cnames
      # print(names(res))
      # print(names(dummydf))
      #Check if names are different, print difference and quit

      res<-subset(res, select=names(dummydf))
      res<-rbind(dummydf,res)
      res<-res[-c(1:nk),] # remove the dummy
      rownames(res)<-NULL
      chkpntResults<-res
    } else if (restart.file == "DISABLED") {
      print("Not a restart.")
    } else {
      print(paste0("Restart file not found: '", restart.file, "'"))
      print("Aborting!")
      quit()
    }

    if (is.null(chkpntResults)){

      par.set = getParamSet(obj.fun)

      ## represent each discrete value once
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
      # each discrete variable should be represented once, else optimization will fail
      # this checks if design size is less than max number of discrete values

      if (design.size < max_val_discrete){
        print("Aborting! design.size is less than the discrete parameters specified")
        quit()
      }
      else{
         print(paste0("Test passed: design size=", design.size, " must be greater or equal to maximum discrete values=", max_val_discrete))
      }

      design = generateDesign(n = design.size, par.set)

      # this loop modifies the top max_val_discrete designs (design) to have each discrete value represented once
      i = 0
      for (v in par.set$pars){
        i=i+1
        if (v$type == "discrete"){
          index=0
          for (val in v$values){
            index=index+1
            design[[i]][index] = val
          }
        }
      }
    } else {
      	design = chkpntResults
    }
    # print(paste("design:", design))
    configureMlr(show.info = FALSE, show.learner.output = FALSE, on.learner.warning = "quiet")
    res = mbo(obj.fun, design = design, learner = NULL, control = ctrl, show.info = TRUE)
    return(res)
  }

  # Ask for parameters from Swift over queue
  OUT_put("Params")

  # Receive parameters message from Swift over queue
  # This is a string of R code containing arguments to main_function(),
  # e.g., "max.budget = 110, max.iterations = 10, design.size = 10, ..."
  msg <- IN_get()
  print(paste("Received params1 msg: ", msg))

  # Edit the R code to make a list constructor expression
  code = paste0("list(",msg,")")

  # Parse the R code, obtaining a list of unevaluated expressions
  # which are parameter=value , ...
  expressions <- eval(parse(text=code))

  # Process the param set file and remove it from the list of expressions:
  #  it is not an argument to the objective function
  source(expressions$param.set.file)
  expressions$param.set.file <- NULL

  # dummy objective function, only par.set is used
  # and param.set is sourced from param.set.file
  obj.fun = makeSingleObjectiveFunction(
    name = "hyperparameter search",
    fn = simple.obj.fun,
    par.set = param.set
  )

  final_res <- do.call(main_function, expressions)
  OUT_put("DONE")

  turbine_output <- Sys.getenv("TURBINE_OUTPUT")
  if (turbine_output != "") {
    setwd(turbine_output)
  }

  res_file <- paste(c(hpo.id, "_final_res.Rds"), collapse = "")
  # This will be saved to experiment directory
  saveRDS(final_res,file = res_file)

  setwd(wd)
  OUT_put("Look at final_res.Rds for final results.")
  print("algorithm done.")
