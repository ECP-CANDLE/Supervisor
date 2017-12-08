from __future__ import print_function

import eqpy, sys

def main():
    print(sys.version)
    eqpy.init("deap_ga")
    eqpy.output_q_get()

    # put in the params
    params = "(1, 2, 1, 'simple', 0.4, './ga_params.json')"
    eqpy.input_q.put(params)

    while True:
        result = eqpy.output_q_get()
        print("test received: {}".format(result))
        if result == "DONE":
            break
        else:
            eqpy.input_q.put("3;3")

    print("Done")


if __name__ == '__main__':
    main()
