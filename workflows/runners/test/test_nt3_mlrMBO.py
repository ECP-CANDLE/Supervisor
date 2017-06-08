import nt3_tc1_runner

def main():

    hyper_parameter_map = {'epochs' : 2}
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['model_name'] = 'tc1'
    hyper_parameter_map['save'] = './tc_output'

    hyper_parameter_map['conv'] = [32, 20, 16, 32, 10, 1]

    nt3_tc1_runner.run(hyper_parameter_map)
    #validation_loss = p1b3_runner.run(hyper_parameter_map)
    #print("Validation Loss: {}".format(validation_loss))
if __name__ == '__main__':
    main()
