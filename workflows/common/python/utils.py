
# UTILS PY

def abort(e, code, message):
    """ Abort with message due to Exception e , return exit code"""
    print(message)
    print(str(e))
    exit(code)
