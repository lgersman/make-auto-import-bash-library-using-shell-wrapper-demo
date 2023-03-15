# suppress verbose make output
MAKEFLAGS += --silent

# test shell command BEFORE out shell wrapper gets initialized
$(info test default shell function pwd=$(shell pwd))

# initialize bash-wrapper
include $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/bash-wrapper.mk

# configure our bash library to be loaded by bash-wrapper everytime a shell is instantiated by make 
.BW_ALWAYS_PRELOAD := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/lib.bash
.BW_ALWAYS_PRELOAD += $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/other-lib.bash

# debug feature: enable verbose debug output for the shell wrapper
# .BW_XTRACE := true

# debug feature: enable to just dump the generated bash code and exit 
# .BW_DUMP := true

#
# test the availability of the bash library functions 
# in make recipes and make shell functions
#

$(info test wrapped shell function whoami=$(shell whoami)) 
$(info test wrapped shell function to_uppercase whoami=$(shell to_uppercase $$(whoami)))
$(info test wrapped shell function pwd=$(shell pwd))

# .ONESHELL tells make to execute a target recipe as a single SHELL call
.ONESHELL:

.PHONY: all 
# et voilà : the recipe can use automatically exported functions/symbols from `lib.bash` 
all: 
	# output result of calling a bash function defined in other-lib.bash
	$(info $(shell my.hello "world"))

	# reference variable from lib.bash
	echo "MY_SETTING=$$MY_SETTING"

	# use exported function from lib.bash
	echo "lowercased : $$(lib:to_lowercase $$MY_SETTING)"

	# use exported function with namespace from lib.bash
	echo "uppercased : $$(to_uppercase $$MY_SETTING)"

	# print splitted PATH environment 
	# (just to ensure if bashrc & co are loaded)
	printf "\n==== PATH environment ====\n"
	printf "%s\n" $$(echo $$PATH | tr ":" $$'\n')
