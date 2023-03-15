# suppress verbose make output
MAKEFLAGS += --silent

$(info pwd=$(shell pwd))

# set absolute path to bash executable as SHELL
SHELL != sh -c "command -v bash"

# -i (interactive mode) is required by bash to force 
# interpretation of the --rcfile option
.SHELLFLAGS := --rcfile ./lib.bash -ic -- 

# et voilà : we can use functions/symbols defined in lib.bash in the makefile shell function 
$(info lowercased: $(shell lib:to_lowercase $$MY_SETTING))

# plain command execution works also
$(info pwd=$(shell pwd))


# BUT ... *some* commands will not work
# the reason for not working is probably related to the interactive switch (-i) we need to use 
# to force bash to interpret the --rcfile option
#
# example : $(info whoami=$(shell whoami))
# 

# .ONESHELL tells make to execute a target recipe as a single SHELL call
.ONESHELL:

.PHONY: all 
# et voilà : the recipe can use automatically exported functions/symbols from `lib.bash` 
all: 
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
