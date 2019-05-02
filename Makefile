SOURCES := $(shell find . -name '*.toml' -or -name '*.md')

build : $(SOURCES)
	hugo

clean :
	rm -r -f public
