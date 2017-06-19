r <- getOption("repos")
r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
options(repos = r)

# Force Plotly 4.5.6 - not latest! Do not want shiny/httpuv, it does not work on Cooley!
install.packages("https://cran.r-project.org/src/contrib/Archive/plotly/plotly_4.5.6.tar.gz", Ncpus=4)
install.packages("smoof", Ncpus=4)
install.packages("mlrMBO", Ncpus=4)
install.packages("rgenoud", Ncpus=4)
install.packages("DiceKriging", Ncpus=4)
install.packages("randomForest", Ncpus=4)
install.packages("RInside", Ncpus=4)
