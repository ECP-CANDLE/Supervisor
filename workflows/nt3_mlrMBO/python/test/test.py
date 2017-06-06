import nt3_runner

def main():

    hyper_parameter_map = {'epochs' : 2}
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['save'] = './output'

    hyper_parameter_map['conv'] = [32, 20, 16, 32, 10, 1]

    nt3_runner.run(hyper_parameter_map)
    #validation_loss = p1b3_runner.run(hyper_parameter_map)
    #print("Validation Loss: {}".format(validation_loss))
if __name__ == '__main__':
    main()
