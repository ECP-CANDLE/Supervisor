# UTILS PY

import os


def fail(*args):
    if len(args) == 1:
        fail1(args[0])
    elif len(args) == 3:
        fail3(*args)


def fail1(message):
    """Fail with message, return exit code 1."""
    print(message)
    exit(1)


def fail3(e, code, message):
    """Fail with message due to Exception e , return exit code."""
    print(message)
    print(str(e))
    exit(code)


def avg(values):
    total = sum(values)
    return total / len(values)


def append(filename, text):
    try:
        with open(filename, "a") as fp:
            fp.write(text)
            fp.write("\n")
    except Exception as e:
        fail(e, os.EX_IOERR, "Could not append to: " + filename)


import re


class Matcher:
    """Abstract class for use with Grepper."""

    def __init__(self, regexp):
        self.regexp = regexp
        self.pattern = re.compile(self.regexp)

    def match(self, line):
        m = self.pattern.match(line)
        if m is None:
            return None
        self.run(line)

    def run(self, line):
        """User code should override this."""
        pass

    def reset(self):
        """User code should override this."""
        pass


class Grepper:

    def __init__(self, matchers):
        """matchers: List of Matchers"""
        self.matchers = matchers

    def grep(self, filename):
        with open(filename, "r") as fp:
            while True:
                line = fp.readline()
                if len(line) == 0:
                    break
                for matcher in self.matchers:
                    matcher.match(line)

    def reset(self):
        for matcher in self.matchers:
            matcher.reset()


def columnPrint(D, aligns):
    """D: a dict mapping a header string to a list of string data"""
    """ aligns: a string "llrlr" for left or right alignment by column """
    headers = D.keys()
    assert len(aligns) == len(
        headers), "Length of aligns (%i) does not match headers (%i)!" % (
            len(aligns),
            len(headers),
        )

    # Format specs for headers
    fmth = ""
    # Format specs for data
    fmtd = ""
    maxlist = 0
    index = 0  # To track aligns
    for header in headers:
        maxstr = len(header)
        if len(D[header]) > maxlist:
            maxlist = len(D[header])
        for item in D[header]:
            if len(item) > maxstr:
                maxstr = len(item)
        # Header is always left-aligned
        fmth += "%%-%is " % maxstr
        sign = "-" if aligns[index] == "l" else ""
        fmtd += "%%%s%is " % (sign, maxstr)
        index += 1
    # Start printing
    print(fmth % tuple(headers))
    for i in range(0, maxlist - 1):
        L = []
        for header in headers:
            L.append(D[header][i])
        print(fmtd % tuple(L))
