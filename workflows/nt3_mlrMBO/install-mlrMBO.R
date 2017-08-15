
# Obsolete: use /workflows/common/R/install-candle.sh

r <- getOption("repos")
r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
options(repos = r)

# Force Plotly 4.5.6 - not latest! Do not want shiny/httpuv, it does not work on Cooley!
install.packages("https://cran.r-project.org/src/contrib/Archive/plotly/plotly_4.5.6.tar.gz")
install.packages("smoof")
install.packages("mlrMBO")
install.packages("rgenoud")
install.packages("DiceKriging")
