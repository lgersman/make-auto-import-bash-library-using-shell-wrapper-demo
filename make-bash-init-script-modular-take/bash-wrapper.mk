# partly borrowed from a prior art project 
# see 
# 	https://github.com/nclsgd/makebashwrapper 
# 	Copyright 2017-2020 Nicolas Godinho <nicolas@godinho.me>

# Inclusion guard
ifndef ._BW_defined
	override ._BW_defined := yes

	# undefine any .BW_ variables that may be (unintended) inherited
	# from the environment or the Make command line variables
	override undefine .BW_PATH
	override undefine .BW_PRELOAD
	override undefine .BW_PROLOGUE
	override undefine .BW_ALWAYS_PRELOAD
	override undefine .BW_ALWAYS_PROLOGUE

	# it is important that the SHELL and .SHELLFLAGS variables must not be
	# inherited from the environment.
	#
	# We cannot use SHELL=bash with the "bash-wrapper.sh" script
	# as argument to bash. there is a special handling of the recipe lines
	# parsing if the shell is detected to be a bash by gnu make
	# (i.e. /bin/sh, /bin/ksh and so on).  in that scenario, leading `-`, `+` and
	# `@` characters are trimmed within the recipe content. This preprocessing may
	# break some bash scripts that we want to inject into the wrapper script.
	# let's stick with the path to "bash-wrapper.sh" file marked as executable.
	# @see the GNU Make source code and read function
	# `construct_command_argv_internal()` (see the few lines that follow the call
	# to the function `is_bourne_compatible_shell` within it).
	#
	override SHELL := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/bash-wrapper.sh
	# transform configured bash scripts to commandline options provided to our bash-wrapper main() function later on
	# note that this variable is lazy evaluated which in turn means 
	# that it is evaluated again each time it gets accessed
	override .SHELLFLAGS = $(foreach ._item,$(.BW_PRELOAD),--preload $(._item)) \
		$(foreach ._item,$(.BW_PROLOGUE),--prologue $(._item)) \
		$(foreach ._item,$(.BW_ALWAYS_PRELOAD),--always-preload $(._item)) \
		$(foreach ._item,$(.BW_ALWAYS_PROLOGUE),--always-prologue $(._item)) \
		--

	# explicitly do *NOT* export SHELL as it may break some scripts or third-party
	# programs used in make recipes since at this current point, SHELL is the path
	# to "bash-wrapper.sh" (see above) which is not a real true shell.
	unexport SHELL
endif 