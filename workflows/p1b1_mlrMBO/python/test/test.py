import p1b1_runner, os


def main():

    hyper_parameter_map = {'epochs' : 2}
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['model_name'] = 'p1b1'
    hyper_parameter_map['timeout'] = 3600
    hyper_parameter_map['save'] = './p1b1_output'

    p1b1_runner.run(hyper_parameter_map)

if __name__ == '__main__':
    main()
