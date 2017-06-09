import p1b1_runner

def main():

    hyper_parameter_map = {'epochs' : 1}
    hyper_parameter_map['batch_size'] = 40
    hyper_parameter_map['dense'] = [1900, 500] 
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['save'] = './p1bl1_output'

    validation_loss = p1b1_runner.run(hyper_parameter_map)
    print("Validation Loss: ", validation_loss)
if __name__ == '__main__':
    main()
