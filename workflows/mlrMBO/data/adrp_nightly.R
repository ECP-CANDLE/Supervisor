param.set <- makeParamSet(
  makeIntegerParam("epochs", lower = 90, upper = 90),
  makeNumericParam("dropout", lower = 0.1, upper = 0.2),
  makeNumericParam("learning_rate", lower = 0.00001, upper = 0.001),
  makeDiscreteParam("activation", values = c("elu", "linear", "relu", "sigmoid", "tanh")),
  makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop")),
  makeDiscreteParam("dense", values = c("500 250 125 60 30", "250 125 60 30", "400 150 75 30","300 175 90 45 20","400 200 100 50 25", "350 170 85 40 20"))
)

