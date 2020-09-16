
# INSTALL CANDLE R

# Run this via install-candle.sh
# Installs all R packages needed for Supervisor workflows

# mlrMBO may need APT packages libxml2-dev libssl-dev curl-dev

NCPUS = 16

r <- getOption("repos")
# r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
r["CRAN"] <- "http://cran.wustl.edu/"
options(repos = r)

# Force Plotly 4.5.6 - not latest! Do not want shiny/httpuv, it does not work on Cooley!
install.packages("https://cran.r-project.org/src/contrib/Archive/plotly/plotly_4.5.6.tar.gz")
install.packages("https://cran.r-project.org/src/contrib/Archive/jsonlite/jsonlite_1.7.0.tar.gz") # ALW adding this on 9/12/20 (and removing jsonlite from PKGS list below) because sometime in the first two weeks of Sept 2020 the default jsonlite version became 1.7.1 and this seems to throw an error that looks to me like a bug that should be fixed with time; e.g., while everything worked in early Sept 2020 (probably 9/2/20), now on 9/12/20 I get this error:
# * DONE (jsonlite)
# 1): succeeded '/usr/local/apps/R/4.0/4.0.0/lib64/R/bin/R CMD INSTALL -l '/gpfs/gsfs9/users/BIDS-HPC/public/software/distributions/candle/dev_2/builds/R/libs' '/lscratch/64803361/Rtmpnd5yDC/downloaded_packages/jsonlite_1.7.1.tar.gz''
# The downloaded source packages are in
# 	‘/lscratch/64803361/Rtmpnd5yDC/downloaded_packages’
# [1] ""
# LOAD:     jsonlite 
# Error in value[[3L]](cond) : 
#   Package ‘jsonlite’ version 1.7.0 cannot be unloaded:
#  Error in unloadNamespace(package) : namespace ‘jsonlite’ is imported by ‘plotly’ so cannot be unloaded
# Calls: library ... tryCatch -> tryCatchList -> tryCatchOne -> <Anonymous>
# Execution halted
# ****NOTE**** that I tried installing both plotly and jsonlite the normal way (in the PKGS below instead of a specific version above) and I got the same error

PKGS <- list(
    "smoof",
    "rgenoud",
    "DiceKriging",
    "randomForest",
    "parallelMap",
    "RInside",
    "mlrMBO"
)

for (pkg in PKGS) {
  print("")
  cat("INSTALL: ", pkg, "\n")
  # install.packages() does not return an error status
  install.packages(pkg, Ncpus=NCPUS, verbose=TRUE)
  print("")
  # Test that the pkg installed and is loadable
  cat("LOAD:    ", pkg, "\n")
  library(package=pkg, character.only=TRUE)
}

print("INSTALL-CANDLE: OK")
