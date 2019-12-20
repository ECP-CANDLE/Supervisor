
# UTILS PY

def fail(e, code, message):
    """ Fail with message due to Exception e , return exit code"""
    print(message)
    print(str(e))
    exit(code)

def fail(message):
    """ Fail with message return exit code"""
    print(message)
    exit(1)
