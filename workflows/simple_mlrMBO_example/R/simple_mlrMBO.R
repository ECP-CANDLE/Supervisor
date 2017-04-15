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

  dots <- list(...)
  string_params <- elements_of_lists_to_string(dots[[1L]])
  print(paste0("parallelMap2 called with list_param: ",string_params))
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

require(parallelMap)

unlockBinding("parallelMap", as.environment("package:parallelMap"))
assignInNamespace("parallelMap", parallelMap2, ns="parallelMap", envir=as.environment("package:parallelMap"))
assign("parallelMap", parallelMap2, as.environment("package:parallelMap"))
lockBinding("parallelMap", as.environment("package:parallelMap"))

library(mlrMBO)

simple.obj.fun = function(x){
  sum(x^2)
}

# dummy objective function but the par.set is actually used
obj.fun = makeSingleObjectiveFunction(
  name = "Numeric 2D",
  fn = simple.obj.fun,
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -5, upper = 5),
    makeNumericParam("x2", lower = -10, upper = 20)
  )
)



main_function <- function(pp = 2, it = 5){
  ctrl = makeMBOControl(propose.points = pp)
  ctrl = setMBOControlInfill(ctrl, crit = crit.ei)
  ctrl = setMBOControlMultiPoint(ctrl, method = "cl", cl.lie = min)
  ctrl = setMBOControlTermination(ctrl, iters = it)
  #ctrl = setMBOControlTermination(ctrl, max.evals = 10)
  configureMlr(on.learner.warning = "quiet", show.learner.output = FALSE)

  res = mbo(obj.fun, control = ctrl, show.info = FALSE)
  return(res)
}

# ask for parameters from queue
OUT_put("Params")
# accepts arguments to main_function, e.g., "pp = 2, it = 5"
res <- IN_get()

l <- eval(parse(text = paste0("list(",res,")")))
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
