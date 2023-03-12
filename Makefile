TEMPLATES := $(shell find . -type f -executable -name '*.template')
TEMPLATE_TARGETS := $(patsubst %.template,%, $(TEMPLATES))

all: $(TEMPLATE_TARGETS)

% : %.template
	cd $(<D) && ./$(<F)

clean:
	rm -f -- $(TEMPLATE_TARGETS)

.PHONY: all clean