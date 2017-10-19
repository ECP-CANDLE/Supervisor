import combo_runner, os


def main():

    hyper_parameter_map = {'epochs' : 1}
    hyper_parameter_map['dense'] = [1000, 1000, 1000, 1000, 1000]
    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['model_name'] = 'combo'
    hyper_parameter_map['timeout'] = 3600
    hyper_parameter_map['save'] = './combo_output'
    hyper_parameter_map['batch_size'] = 256
    hyper_parameter_map['use_landmark_genes'] = True
    hyper_parameter_map['reduce_lr'] = True
    hyper_parameter_map['warmup_lr'] = True

    combo_runner.run(hyper_parameter_map, "val_loss")

if __name__ == '__main__':
    main()
