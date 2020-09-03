
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

PKGS <- list(
    "smoof",
    "rgenoud",
    "DiceKriging",
    "randomForest",
    "jsonlite",
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
