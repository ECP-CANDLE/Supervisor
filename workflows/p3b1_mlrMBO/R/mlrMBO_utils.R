# Utility code to transform elements to strings and vice versa
library(jsonlite)

elements_to_string <- function(x){
  paste0(x,collapse = ",")
}

elements_of_elements_to_string <- function(x){
  paste0(sapply(x,elements_to_string),collapse = ';')
}

list_to_string <- function(x){
  toString(x)
}

elements_of_lists_to_json <- function(x){
  paste0(sapply(x,toJSON,auto_unbox = T),collapse = ';')
}
string_to_list_of_vectors <- function(x){
  lapply(unlist(strsplit(x,";")),function(y) as.numeric(unlist(strsplit(y,","))))
}

# For a result element, res_element, append user extras if they exist
append_extras_if_exist <- function(res_element,x){
  if (length(x) > 1){
    res_element = c(res_element, list(user.extras = as.list(x[-1])))
  }
  res_element
}

result_with_extras_if_exist <- function(res,time_value){
  lapply(res, function(x) append_extras_if_exist(c(list(y=x[1]),
                                                   list(time=time_value)),x))
}

strsubst <-
function(template, map, verbose=getOption("verbose")) {
  pat <- "\\$\\([^\\)]+\\)"
  res <- template
  map[["$"]] <- "$"
  m <- gregexpr(pat, template)
  idx <- which(sapply(m, function(x) x[[1]]!=-1)) # faster than 1:length(template)?
  for (i in idx) {
    line <- template[[i]]
    if(verbose) cat("input: |", template[[i]], "|\n")
    starts <- m[[i]]
    ml <- attr(m[[i]], "match.length")
    sym <- substring(line, starts+2, starts+ml-2)
    repl <- map[sym]
    idx1 <- is.null(repl)
    repl[idx1] <- sym[idx1]
    norepl <- substring(line, c(1, starts+ml), c(starts-1, nchar(line)))
    res[[i]] <- paste(norepl, c(repl, ""), sep="", collapse="") # more elegant?
    if (verbose) cat("output: |", res[[i]], "|\n")
  }
  return(res)
}
