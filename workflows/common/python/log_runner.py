import sys

import exp_logger


def log_start():
    parameter_map = {}
    parameter_map["pp"] = sys.argv[2]
    parameter_map["iterations"] = sys.argv[3]
    parameter_map["params"] = '"""{}"""'.format(sys.argv[4])
    parameter_map["algorithm"] = sys.argv[5]
    parameter_map["experiment_id"] = sys.argv[6]
    sys_env = '"""{}"""'.format(sys.argv[7])

    exp_logger.start(parameter_map, sys_env)


def log_end():
    exp_id = sys.argv[2]
    exp_logger.end(exp_id)


def main():
    print(sys.argv)
    if sys.argv[1] == "start":
        log_start()
    else:
        log_end()


if __name__ == "__main__":
    main()
