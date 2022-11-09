
# INSTALL CANDLE R

# Run this via install-candle.sh
# Installs all R packages needed for Supervisor workflows

# mlrMBO may need APT packages libxml2-dev libssl-dev curl-dev

NCPUS = 16

r <- getOption("repos")
# Change this mirror as needed:
# r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
r["CRAN"] <- "http://cran.wustl.edu/"
options(repos = r)

# Do plotly early in the list: It requires OpenSSL and Curl headers
# which may not be available.
PKGS <- list(
    "RInside",
    "plotly",
    "jsonlite",
    "rgenoud",
    "DiceKriging",
    # not available for R 3.6.1 : needed for mlrMBO HPO:
    "randomForest",
    "parallelMap",
    # requires smoof requires misc3d requires --with-tcltk :
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
