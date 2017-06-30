# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by the benchmark


param.set <- makeParamSet(
  makeNumericParam("learning_rate", lower= 0.00001, upper= 0.1 ),
  makeNumericParam("dropout", lower= 0, upper= 0.9 ),
  makeDiscreteParam("activation", 
    values= c( "softmax","elu","softplus","softsign",
               "relu", "tanh","sigmoid","hard_sigmoid",
               "linear") ),
  makeDiscreteParam("optimizer", 
    values = c("adam", "sgd", "rmsprop","adagrad",
               "adadelta")),
  makeDiscreteParam("shared_nnet_spec", 
    values= c( "400", "500", "600", "700", 
               "800", "900", "1000", "1100",  "1200", 
               "400,400", "500,500", "600,600", "700,700", 
               "800,800", "900,900", "1000,1000", "1100,1100", 
               "1200,1200" ) ),
  makeDiscreteParam("ind_nnet_spec",
    values= c( "400:400:400", "600:600:600", 
               "800:800:800", "1000:1000:1000",
               "1200:1200:1200",
               "400,400:400,400:400,400", "600,600:600,600:600,600", 
               "800,800:800,800:800,800", "1000,1000:1000,1000:1000,1000",
               "1200,1200:1200,1200:1200,1200",
               "800,400:800,400:800,400",
               "1200,400:1200,400:1200,400",
               "1200,800,400:1200,800,400:1200,800,400"
  ) ),
  makeDiscreteParam("batch_size", values = c(16,32,64,128,256)),
  makeIntegerParam("epochs", lower = 10, upper = 100)
)


