
.DELETE_ON_ERROR:

OUTS = $(wildcard out-*.log)

SUMMARIES = $(subst out-,summary-,$(OUTS))

all: $(SUMMARIES)

summary-%.log: out-%.log
	@ ${THIS}/shrink-log-single.sh $(<) $(@)
