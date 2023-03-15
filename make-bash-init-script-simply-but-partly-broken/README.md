# Demo Makefile automatically providing bash exports from a bash init file to make recipes  

This example is a plain & simple effort to implement automatic bash script injection for make shell calls.

It simply reuses the bash `--rcfile` option to force bash to load a script file right before executing the shell code provided by make (i.e. the recipe or shell function argument).

This solution works for many use cases (i.e. all shell recipes) but NOT for all cases. 

Example: Calling a make shell function like `$(info whoami=$(shell whoami))` will abort the make process.
`$(info whoami=$(shell pwd))` will work in contrast. 

In other words the `--rcfile` effort is working in simple scenarios but is not a stable solution at all.

The reason is that we need to switch bash to be in interactive mode (using switch `-i`) to force the `--rcfile` option to be interpreted.

Take a peek to [../make-bash-init-script-modular-take](../make-bash-init-script-modular-take) to see the "gold" solution for bash file injection into Makefile recipes and shell functions. 

## Prerequisites

- GNU make

- Bash

## Usage

Change to this directory and execute `make` 

--- 

`Makefile` :

```make
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
```

bash exports (`lib.bash`) : 

```shell
#
# this is a custom bash library exposing some functions/symbols
#

export MY_SETTING="This-Is-My-Setting-Value"

# define a bash function
function to_uppercase() {
  echo "${1^^}"
}
# export it for use in sub shells
export -f to_uppercase

# bonus: bash shells may contains colon (':') in name
# making this functions kinda 'namespace'd  
function lib:to_lowercase() {
  echo "${1,,}"
}
# export it for use in sub shells
export -f lib:to_lowercase
```

