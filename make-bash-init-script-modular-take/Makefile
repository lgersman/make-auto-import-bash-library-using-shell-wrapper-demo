# suppress verbose make output
MAKEFLAGS += --silent

$(info default-inline-shell pwd=$(shell pwd))

# Override and undefine any .MAKEBASHWRAPPER_ variables that may be inherited
# from the environment or the Make command line variables or even earlier in
# the Makefile inclusion list:
override undefine .MAKEBASHWRAPPER_PATH
override undefine .MAKEBASHWRAPPER_PRELOAD
override undefine .MAKEBASHWRAPPER_PROLOGUE
override undefine .MAKEBASHWRAPPER_ALWAYS_PRELOAD
override undefine .MAKEBASHWRAPPER_ALWAYS_PROLOGUE

# It is important that the SHELL and .SHELLFLAGS variables must not be
# inherited from the environment. Override them and set them as requested:
#
# Note regarding SHELL: We cannot use SHELL=bash with the "wrapper.sh" script
# as argument to bash.  There is a special handling of the recipe lines
# parsing if the shell is detected to be a Bourne compatible shell by GNU Make
# (i.e. /bin/sh, /bin/ksh and so on).  In that scenario, leading `-`, `+` and
# `@` characters are trimmed within the recipe content.  This preprocessing may
# break some Bash scripts that we want to inject into the wrapper script.
# Let's stick with the path to "wrapper.sh" file marked as executable.
# For more information, see the GNU Make source code and read function
# `construct_command_argv_internal()` (see the few lines that follow the call
# to the function `is_bourne_compatible_shell` within it).
#
override SHELL := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/bash-wrapper.sh
override .SHELLFLAGS = $(foreach ._item,$(.MAKEBASHWRAPPER_PRELOAD),--preload $(._item)) \
	$(foreach ._item,$(.MAKEBASHWRAPPER_PROLOGUE),--prologue $(._item)) \
	$(foreach ._item,$(.MAKEBASHWRAPPER_ALWAYS_PRELOAD),--always-preload $(._item)) \
	$(foreach ._item,$(.MAKEBASHWRAPPER_ALWAYS_PROLOGUE),--always-prologue $(._item)) \
	--

# Explicitly do *NOT* export SHELL as it may break some scripts or third-party
# programs used in Make recipes since at this current point, SHELL is the path
# to "wrapper.sh" (see above) which is not a real true shell.
unexport SHELL

# export MAKEBASHWRAPPER_XTRACE := true
.MAKEBASHWRAPPER_ALWAYS_PRELOAD := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/lib.bash

$(info test-inline-shell whoami=$(shell whoami)) 
$(info test-inline-shell to_uppercase whoami=$(shell to_uppercase whoami))
$(info test-inline-shell pwd=$(shell pwd))

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
