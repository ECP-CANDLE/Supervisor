r <- getOption("repos")
r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
options(repos = r)

install.packages("rgenoud",      Ncpus=4)
install.packages("DiceKriging",  Ncpus=4)
install.packages("randomForest", Ncpus=4)
