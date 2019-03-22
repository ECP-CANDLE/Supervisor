

param.set <- makeParamSet (
    makeDiscreteParam("activation", values=c("relu", "sigmoid", "tanh")),
    makeDiscreteParam("dense", values = c("1000 1000 1000", "1000 1000 1000 1000", "1000 1000 1000 1000 1000", "1000 1000 1000 1000 1000 1000",
                                        "2000 2000 2000", "2000 2000 2000 2000", "2000 2000 2000 2000 2000", "2000 2000 2000 2000 2000 2000")),
    makeDiscreteParam("dense_feature_layers", values = c("1000 1000 1000", "1000 1000 1000 1000", "1000 1000 1000 1000 1000", "1000 1000 1000 1000 1000 1000",
                                        "2000 2000 2000", "2000 2000 2000 2000", "2000 2000 2000 2000 2000", "2000 2000 2000 2000 2000 2000")),
    makeDiscreteParam("drop", c(0.0, 0.1, 0.15, 0.2, 0.25)),
    makeDiscreteParam("optimizer", values = c("adam", "sgd", "rmsprop", "adagrad", "adadelta", "nadam", "adamax")),
    makeDiscreteParam("residual", values = c(0, 1)),
    makeIntegerParam("epochs", lower=2, upper=2),
    makeIntegerParam("batch_size", lower=6144, upper=6144)

)
