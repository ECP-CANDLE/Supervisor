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

#1 # p1b1 
    # hyper_parameter_map['save'] = './p1bl1_testing_failure'
    print("STARTING#####P1B1##########")
    ts_p1b1 = datetime.now()
    p1b1_validation_loss = p1b1_runner.run(hyper_parameter_map)
    te_p1b1 = datetime.now()
    print("Validation loss=",p1b1_validation_loss)
    print("DONE##########P1B1#####, TIME=", te_p1b1 - ts_p1b1)


#2 # p1b3 
    print("STARTING#####P1B3##########")
    ts_p1b3 = datetime.now()
    p1b3_validation_loss = p1b3_runner.run(hyper_parameter_map)
    te_p1b3 = datetime.now()
    print("Validation loss=",p1b3_validation_loss)
    print("DONE##########P1B3#####, TIME=", te_p1b3 - ts_p1b3)

#3 # p2b1 
    print("STARTING#####P2B1##########")
    ts_p2b1 = datetime.now()
    p2b1_validation_loss = p2b1_runner.run(hyper_parameter_map)
    te_p2b1 = datetime.now()
    print("Validation loss=",p2b1_validation_loss)
    print("DONE##########P2B1#####, TIME=", te_p2b1 - ts_p2b1)

#4 # p3b1 
    print("STARTING#####P3B1##########")
    ts_p3b1 = datetime.now()
    p3b1_validation_loss = p3b1_runner.run(hyper_parameter_map)
    te_p3b1 = datetime.now()
    print("Validation loss=",p3b1_validation_loss)
    print("DONE##########P3B1#####, TIME=", te_p3b1 - ts_p3b1)

#5 # NT3 
    print("STARTING#####NT3##########")
    hyper_parameter_map['model_name'] = 'nt3'
    ts_nt3 = datetime.now()
    nt3tc1_validation_loss = nt3_tc1_runner.run(hyper_parameter_map)
    te_nt3 = datetime.now()
    print("Validation loss=",nt3tc1_validation_loss)
    print("DONE##########NT3#####, TIME=", te_nt3 - ts_nt3)

if __name__ == '__main__':
    main()

