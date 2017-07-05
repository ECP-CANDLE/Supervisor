import p1b1_runner
import p2b1_runner
import p1b3_runner
import p3b1_runner
import nt3_tc1_runner

def main():

    hyper_parameter_map = {'epochs' : 1}
    hyper_parameter_map['framework'] = 'keras'
    # hyper_parameter_map['save_path'] = save_path
#     hyper_parameter_map = {'epochs' : 1}
#     hyper_parameter_map['batch_size'] = 40
#     hyper_parameter_map['dense'] = [1219, 536] 
#     hyper_parameter_map['framework'] = 'keras'


#1 # p1b1 - works
#     hyper_parameter_map['save'] = './p1bl1_testing_failure'
    print("STARTING#####P1B1##########")
    p1b1_validation_loss = p1b1_runner.run(hyper_parameter_map)
    print("DONE##########P1B1#####")


#2 # p1b3 - works too big for desktop
    print("STARTING#####P1B3##########")
    p1b3_validation_loss = p1b3_runner.run(hyper_parameter_map)
    print("DONE######P1B3#########")

#3 # p2b1 - works
    print("STARTING#####P2B1##########")
    p2b1_validation_loss = p2b1_runner.run(hyper_parameter_map)
    print("DONE#####P2B1##########")

#4 # p3b1 - fails - ValueError: invalid literal for int() with base 10: '1200;1200'
    print("STARTING#####P3B1##########")
    p3b1_validation_loss = p3b1_runner.run(hyper_parameter_map)
    print("DONE#####P3B1##########")

#5 # NT3 - works - too big 
    print("STARTING#####NT3##########")
    hyper_parameter_map['model_name'] = 'nt3'
    nt3tc1_validation_losss = nt3_tc1_runner.run(hyper_parameter_map)
    print("DONE#####NT3##########")

#     # print("Validation Loss: ", p1b1_validation_loss)
if __name__ == '__main__':
    main()
