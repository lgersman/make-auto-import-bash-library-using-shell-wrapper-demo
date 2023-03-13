# suppress verbose make output
MAKEFLAGS += --silent

$(info pwd=$(shell pwd))

# set absolute path to bash executable as SHELL
SHELL != sh -c "command -v bash"

.SHELLFLAGS := --rcfile ./lib.bash -ic -- 

# PROBLEM: will not work for whatever reason
# $(info whoami=$(shell whoami))

$(info pwd=$(shell pwd))

# .ONESHELL tells make to execute a target recipe as a single SHELL call
.ONESHELL:

.PHONY: all 
# et voilà : the recipe can use automatically exported functions/symbols from `lib.bash` 
all: 
	# reference variable from lib.bash
	echo "MY_SETTING=$$MY_SETTING"

	# use exported function from lib.bash
	echo "lowercased : $$(to_uppercase $$MY_SETTING)"

	# use exported function with namespace from lib.bash
	echo "uppercased : $$(lib:to_lowercase $$MY_SETTING)"

	# print splitted PATH environment 
	# (just to ensure if bashrc & co are loaded)
	printf "\n==== PATH environment ====\n"
	printf "%s\n" $$(echo $$PATH | tr ":" $$'\n')
