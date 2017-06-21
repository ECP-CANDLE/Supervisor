import p3b1_runner
import os

def main():

    hyper_parameter_map = {'epochs' : 2}
    hyper_parameter_map['framework'] = 'keras'
    save_path = "./output"
    hyper_parameter_map['save_path'] = save_path

    if not os.path.exists(save_path):
        os.makedirs(save_path)

    validation_loss = p3b1_runner.run(hyper_parameter_map)
    print("Validation Loss: {}".format(validation_loss))
if __name__ == '__main__':
    main()
