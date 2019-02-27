
# RECORD PY
# Represent a record in the DB

class Record:

    def __init__(self):
        self.features = []
        self.studies  = []

    def scan(self, row):
        self.rowid, self.ts, self.cutoff_corr, self.cutoff_xcorr = \
                row[0:4]


    def print(self):
        print("record:       " + str(self.rowid))
        print("timestamp:    " + self.ts)
        print("cutoff_corr:  " + str(self.cutoff_corr))
        print("cutoff_xcorr: " + str(self.cutoff_xcorr))
        print("features:     " + ", ".join(self.features))
        print("studies:      " + ", ".join(self.studies))
