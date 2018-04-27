
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

    if (depth(list_of_lists) == 1):
        list_of_lists = [list_of_lists]

    for l in list_of_lists:
        jmap = {}
        for i,p in enumerate(params):
            jmap[p] = l[i]

        jstring = json.dumps(jmap, cls=MyEncoder)
        result.append(jstring)

    return result
