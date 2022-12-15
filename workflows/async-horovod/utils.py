import json


class MyEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return super(MyEncoder, self).default(obj)


def is_integer(v):
    try:
        t = v + 1
    except:
        return False
    return True


def check(condition, msg):
    if not condition:
        fail(msg)


def fail(msg):
    print(msg)
    import sys

    sys.exit(1)


def string2level(s):
    import logging

    table = {"": logging.INFO, "INFO": logging.INFO, "DEBUG": logging.DEBUG}
    check(s in table, "Invalid log level: " + s)
    return table[s]


def depth(l):
    if isinstance(l, list):
        return 1 + max(depth(item) for item in l)
    else:
        return 0


def create_list_of_json_strings(list_of_lists, params, super_delim=";"):

    if len(list_of_lists) == 0:
        return []

    # create string of ; separated jsonified maps
    result = []

    if depth(list_of_lists) == 1:
        list_of_lists = [list_of_lists]

    for l in list_of_lists:
        jmap = {}
        for i, p in enumerate(params):
            jmap[p] = l[i]

        jstring = json.dumps(jmap, cls=MyEncoder)
        result.append(jstring)

    return result


def print_namespace(title, ns):
    print("")
    print(title)
    for k, v in vars(ns).items():
        print("  %s %s" % (k, v))
    print("")
