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
```

bash exports (`lib.bash`) : 

```shell
# # see https://github.com/nclsgd/makebashwrapper/blob/master/_mklib_/wrapper/makebashwrapper.sh#L24
# enable useful debugging infos
# PS4='+${BASH_SOURCE[0]}:${LINENO}${FUNCNAME[0]:+:${FUNCNAME[0]}()}: '
# set -x

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

set -e -u -o pipefail
```

