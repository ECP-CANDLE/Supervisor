
# UTILS PY

def fail(*args):
    if len(args) == 1:
        fail1(args[0])
    elif len(args) == 3:
        fail3(*args)

def fail1(message):
    """ Fail with message, return exit code 1 """
    print(message)
    exit(1)

def fail3(e, code, message):
    """ Fail with message due to Exception e , return exit code """
    print(message)
    print(str(e))
    exit(code)

def avg(values):
    total = 0.0
    for v in values:
        total += v
    return total / len(values)

def append(filename, text):
    try:
        with open(filename, 'a') as fp:
            fp.write(text)
            fp.write('\n')
    except Exception as e:
        fail(e, os.EX_IOERR, 'Could not append to: ' + filename)
