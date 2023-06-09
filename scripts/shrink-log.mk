
.DELETE_ON_ERROR:

# Logs on stdout from Python runs
OUTS = $(wildcard out-*.txt)
# Logs in model.log from containers
RUNS = $(shell find . -name model.log)

SUMMARIES = $(subst out-,summary-,$(OUTS)) $(subst model,summary,$(RUNS))

all: $(SUMMARIES)

summary-%.txt: out-%.txt
	@ ${THIS}/shrink-log-single.sh $(<) $(@)

%/summary.log: %/model.log
	@ ${THIS}/shrink-log-single.sh $(<) $(@)
