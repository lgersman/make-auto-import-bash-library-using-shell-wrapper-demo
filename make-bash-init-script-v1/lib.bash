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