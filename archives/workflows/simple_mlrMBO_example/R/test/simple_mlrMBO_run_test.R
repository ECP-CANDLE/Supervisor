source("test/test_utils.R")
# Functions to supply OUT_put and IN_get
for.In_get = ""
last.time = FALSE
OUT_put <- function(x) {
  if (!last.time){
    if (x == "DONE"){
      for.In_get <<- ""
      last.time <<- TRUE
    }
    else if (x == "Params") {
      for.In_get <<- "pp = 2, it = 5"
    }
    else {
      res <- split.into.param.lines(x)
      resFull <- lapply(res,simple.obj.fun)
      for.In_get <<- make.into.q.res(resFull)
    }
  }
  else {
    print(paste0("Final result: ", x))
  }
}
IN_get <- function(){
  print(paste0("returning: ", for.In_get))
  return(for.In_get)
}

## Assumes working directory is ../
source("simple_mlrMBO.R")

## Look at result with: readRDS("final_res.Rds")
