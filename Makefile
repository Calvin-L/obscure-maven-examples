SHELL=bash

SUBPROJECTS=$(shell find . -depth 1 -type d -not -iname '.git' | sort)
DEPFILES=$(addsuffix .d,$(SUBPROJECTS))
OUTPUTS=$(addsuffix .log,$(SUBPROJECTS))

.PHONY: all
all: $(OUTPUTS)

.PHONY: clean
clean:
	$(RM) $(DEPFILES)
	$(RM) $(OUTPUTS)

-include $(DEPFILES)
$(DEPFILES): %.d: Makefile
	@echo 'Generating $@...'
	@echo -n '$@: ' >'$@.tmp'
	@find '$*' \( -iname target -prune \) -or \( -type f -print0 \) | tr '\0' ' ' >>'$@.tmp'
	@echo '' >>'$@.tmp'
	@echo -n '$*.log: ' >>'$@.tmp'
	@find '$*' \( -iname target -prune \) -or \( -type f -print0 \) | tr '\0' ' ' >>'$@.tmp'
	@echo '' >>'$@.tmp'
	@mv '$@.tmp' '$@'

.NOTPARALLEL: $(OUTPUTS)
$(OUTPUTS): %.log: Makefile
	@echo -n 'Building $*... '
	@mvn -f '$*' clean help:effective-pom verify >'$@' 2>&1; \
	    if [[ "$$?" == "0" ]]; then \
	        echo "WORKS"; \
	    else \
	        echo "BROKEN"; \
	    fi
