
# INSTALL CANDLE R

# Run this via install-candle.sh
# Installs all R packages needed for Supervisor workflows

# Installation settings:
r <- getOption("repos")
# r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
r["CRAN"] <- "http://cran.wustl.edu/"
options(repos = r)
NCPUS = 8

# Force Plotly 4.5.6 - not latest!
install.packages("https://cran.r-project.org/src/contrib/Archive/plotly/plotly_4.5.6.tar.gz")

PKGS = list("DiceKriging",
            "jsonlite",
            # mlrMBO may need APT packages libxml2-dev libssl-dev
            "mlrMBO",
            "parallelMap",
            "randomForest",
            "rgenoud",
            "RInside",
            "smoof"
            )

for (pkg in PKGS) {
  install.packages(pkg, Ncpus=NCPUS)
}
