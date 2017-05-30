import p1b3_runner

def main():

    hyper_parameter_map = {'epochs' : 3}
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['feature_subsample'] = 500
    hyper_parameter_map['train_steps'] = 100
    hyper_parameter_map['val_steps'] = 10
    hyper_parameter_map['test_steps'] = 10
    hyper_parameter_map['save'] = './output'

    validation_loss = p1b3_runner.run(hyper_parameter_map)
    print("Validation Loss: {}".format(validation_loss))
if __name__ == '__main__':
    main()
