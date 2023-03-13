# Demo Makefile automatically providing bash exports from a bash init file to make recipes  

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

# test shell command BEFORE out shell wrapper gets initialized
$(info test default shell function pwd=$(shell pwd))

# initialize bash-wrapper
include bash-wrapper.mk

# configure our bash library to be loaded by bash-wrapper everytime a shell is instantiated by make 
.BW_ALWAYS_PRELOAD := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/lib.bash

# enable verbose debug output
# export BW_XTRACE := true

#
# test the availability of the bash library functions 
# in make recipes and make shell functions
#

$(info test wrapped shell function whoami=$(shell whoami)) 
$(info test wrapped shell function to_uppercase whoami=$(shell to_uppercase whoami))
$(info test wrapped shell function pwd=$(shell pwd))

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

