#!/usr/bin/env bash

# partly borrowed from a prior art project 
# see 
# 	https://github.com/nclsgd/makebashwrapper 
# 	Copyright 2017-2020 Nicolas Godinho <nicolas@godinho.me>

# enable bash "strict mode"
set -e -u -o pipefail

# The name of this present script:
readonly SELFNAME="${BASH_SOURCE[0]##*/}"

# enable verbose bash debug info if BW_XTRACE is not empty
if [[ -n "${BW_XTRACE:-}" ]]; then
  echo >&2 "BW_XTRACE is set: activating xtrace."
  PS4='+${BASH_SOURCE[0]}:${LINENO}${FUNCNAME[0]:+:${FUNCNAME[0]}()}: '
  set -x
fi

main() {
  local preloads=() always_preloads=() prologues=() always_prologues=()
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --preload)
        preloads+=("${2:?"missing argument to $1"}")
        shift 2
        ;;
      --always-preload)
        always_preloads+=("${2:?"missing argument to $1"}")
        shift 2
        ;;
      --prologue)
        prologues+=("${2:?"missing argument to $1"}")
        shift 2
        ;;
      --always-prologue)
        always_prologues+=("${2:?"missing argument to $1"}")
        shift 2
        ;;
      --)   # Special argument to break argument parsing
        shift
        break
        ;;  
      -*) 
        echo "$SELFNAME: Unknown option: $1" >&2
        exit 255 
        ;;
      *)    # Not an argument anymore
        break
        ;;  
    esac
  done
  [[ "$#" -gt 1 ]] && echo "$SELFNAME: Too many arguments given" >&2 && exit 255
  
  local script_body="${1:-}"

  # if script_body is empty or only composed of empty lines or comments,
  # then do not process to avoid running (most of the time, involuntarily)
  # code with potential side-effects in the preload scripts or in the
  # prologues.
  local script_body_line='' script_body_has_code=no
  while read -r script_body_line; do
    if ! [[ "$script_body_line" =~ ^[" "\t]*($|\#) ]]; then
      script_body_has_code=yes
      break
    fi
  done <<< "$script_body"
    
  # optimization : abort execution if script consits only of comments
  [[ "$script_body_has_code" != yes ]] && exit 0

  # fix and export SHELL as it is explicitly changed and undefined by the
  # "bash-wrapper.mk" file:
  export SHELL="${BASH:-/bin/sh}"  # BASH should always be set and valid anyway

  # we can now compose the script to be fed to a new bash instance that will
  # replace this current bash instance (see below):
  local script_lines
  script_lines=(
    "#!/usr/bin/env bash"
    "set -e -u -o pipefail  # bash 'strict mode'"
    ""  # line break on purpose
  )

  # Note: MAKELEVEL appears to be the only variable always exported
  # within the recipe scripts whatever the ".EXPORT_ALL_VARIABLES" or
  # "unexport" settings.  We use this side-effect to assert if we are
  # currently running a recipe or not (i.e. a command executed within a
  # `$(shell ...)` make function).  In such case, also preload scripts
  # and unroll prologue meant for the recipes:
  if [[ "${MAKELEVEL:-}" != '' ]]; then
    script_lines+=(
      "# This is a recipe. (MAKELEVEL=${MAKELEVEL:-<undefined>})"
      ""  # line break on purpose
    )
    preloads=( "${always_preloads[@]}" "${preloads[@]}" )
    prologues=( "${always_prologues[@]}" "${prologues[@]}" )
  else
    script_lines+=(
      "# This is not a recipe. (MAKELEVEL is unset or empty)"
      "# Only loading unconditional preload(s) and prologue(s)."
      ""  # line break on purpose
    )
    preloads=( "${always_preloads[@]}" )
    prologues=( "${always_prologues[@]}" )
  fi

  # include/source preloads:
  local item='' has_items=no line=''
  # for item in "${preloads[@]}"; do
  #   if [[ -z "$has_items" ]]; then
  #     script_lines+=( "# Preload scripts:" )
  #     has_items=yes
  #   fi
  #   printf -v line 'source %q' "$item"
  #   script_lines+=( "$line" )
  # done
  if (( "${#preloads[@]}" > 0 )); then
    script_lines+=( "# Preload scripts:" )
    printf -v sources 'source %q\n' "${preloads[@]}"
    script_lines+=( "${sources[@]}" )
    script_lines+=( '' )  # line break
  fi
  # [[ "$has_items" == yes ]] && script_lines+=('')  # line break

  # include/source prologues:
  local item='' has_items=no line=''
  for item in "${prologues[@]}"; do
    if [[ -z "$has_items" ]]; then
      script_lines+=( "# Prologue scripts:" )
      has_items=yes
    fi
    printf -v line 'source %q' "$item"
    script_lines+=( "$line" )
  done
  [[ "$has_items" == yes ]] && script_lines+=('')  # line break

  # append rest of the script (the body, i.e. the Makefile recipe contents):
  script_lines+=(
    "$script_body"
  )

  if [[ -n "${BW_DUMPSCRIPT:-}" ]]; then
    printf '%s\n' "${script_lines[@]}"
    exit 0
  else
    unset_BW_vars_from_environment
    exec "${BASH:-bash}" <(printf '%s\n' "${script_lines[@]}")
  fi
}

unset_BW_vars_from_environment() {
  for var in $(compgen -A export BW_ || :); do
    [[ "$var" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && -n "${!var+set}" ]] && unset "$var"
  done
}

main "$@"
