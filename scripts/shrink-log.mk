
.DELETE_ON_ERROR:

OUTS = $(wildcard out-*.txt)

SUMMARIES = $(subst out-,summary-,$(OUTS))

all: $(SUMMARIES)

summary-%.txt: out-%.txt
	@ ${THIS}/shrink-log-single.sh $(<) $(@)
