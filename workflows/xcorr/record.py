
# RECORD PY
# Represent a record in the DB

class Record:

    def __init__(self):
        self.features = []
        self.studies  = []

    def scan(self, row):
        self.rowid, self.ts, self.filename = row[0:3]

    def print(self):
        print("record:   " + str(self.rowid))
        print("time:     " + self.ts)
        print("filename: " + self.filename)
        print("features: " + ", ".join(self.features))
        print("studies:  " + ", ".join(self.studies))
