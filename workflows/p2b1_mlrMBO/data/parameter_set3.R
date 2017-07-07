# see https://cran.r-project.org/web/packages/ParamHelpers/ParamHelpers.pdfmakeNum
# the parameter names should match names of the arguments expected by
# the benchmark
param.set <- makeParamSet(
  makeDiscreteParam("batch_size", values = c(16, 32, 64, 128, 256, 512)),
  makeIntegerParam("epochs", lower = 5, upper = 50),
  makeDiscreteParam("activation", values = c("softmax","elu","softplus","softsign", 
  				  	   	"relu", "tanh","sigmoid","hard_sigmoid",
						"linear")),
  makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop","adagrad",
  				 	  	    "adadelta")),
  makeNumericParam("learning_rate", lower = 0.001, upper = 0.2),
  makeNumericParam("noise_factor", lower = 0.0, upper = 0.5),
  makeNumericParam("weight_decay", lower = 0.000001, upper = 0.1)
  #makeDiscreteParam("num_hidden", values = c("512 256 128 64 32 16", "512 64")),
  #makeDiscreteParam("molecular_num_hidden", values = c("54 12", "32 16 8"))
  ## DEBUG PARAMETERS: DON'T USE THESE IN PRODUCTION RUN
  ## makeDiscreteParam("conv", values = c("32 20 16 32 10 1"))
)




