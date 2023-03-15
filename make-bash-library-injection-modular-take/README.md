# Demo Makefile automatically providing bash exports from your custom bash libraries to make recipes  

This directory contins a fully functional Makefile example for injecting custom Bash libraries into make targets and make shell functions.

This enables you to out source complex Bash Makefile recipes into separate bash files.

## Features 

- separation of concerns (Makefile flow and Bash recipe logic)

- testing of Bash recipes / Bash logic outside of Make using Shell test frameworks like https://github.com/kward/shunit2 or [bats](https://github.com/bats-core/bats-core)

- your build scripts get much more readable/maintanable

- Makefiles contains just dependency definitions calling Bash functions provided by your Bash library functions

- some bash debugging features like Bash xtrace enablement and dumping the Bash code executed by Make

- composition : you can reuse your bash libraries in various different Makefiles / Repositories

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
```

injected Bash library `lib.bash` : 

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

2nd injected Bash library  (`other-lib.bash`) : 

```shell
#
# this is another custom bash library
# 

function my.hello() {
  echo "hello ${1:-world}"
}

export -f my.hello
```

