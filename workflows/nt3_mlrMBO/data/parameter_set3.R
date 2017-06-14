# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by
# the benchmark
param.set <- makeParamSet(
  makeDiscreteParam("batch_size", values = c(16, 32, 64, 128, 256, 512)),
  makeIntegerParam("epochs", lower = 10, upper = 30),
  makeDiscreteParam("activation", values = c("softmax","elu","softplus","softsign", 
  				  	   	"relu", "tanh","sigmoid","hard_sigmoid",
						"linear" )),
  makeDiscreteParam("dense", values = c("500 100 50", "1000 500 100 50", 
  			     	      	     "2000 1000 500 100 50")),
  makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop","adagrad",
  				 	  	    "adadelta","adamax","nadam")),
  makeNumericParam("drop", lower = 0, upper = 0.5),
  makeDiscreteParam("conv", values = c("50 50 50 50 50 1", "25 25 25 25 25 1", 
  			    	     	   "10 10 1 5 5 1", "32 20 16 32 10 1"))
  ## DEBUG PARAMETERS: DON'T USE THESE IN PRODUCTION RUN
  ## makeDiscreteParam("conv", values = c("32 20 16 32 10 1"))
)

