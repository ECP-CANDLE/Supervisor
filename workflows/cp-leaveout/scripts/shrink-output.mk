
.DELETE_ON_ERROR:

OUTS = $(wildcard out-*.txt)

SUMMARIES = $(subst out-,summary-,$(OUTS))

all: $(SUMMARIES)

/tmp/${USER}/tr-%.txt: out-%.txt
	@ tr "\r" "\n" < $(<) > $(@)

summary-%.txt: /tmp/${USER}/tr-%.txt
	@ python $(THIS)/shrink-output.py $(<) $(@)
