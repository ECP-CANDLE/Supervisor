
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
