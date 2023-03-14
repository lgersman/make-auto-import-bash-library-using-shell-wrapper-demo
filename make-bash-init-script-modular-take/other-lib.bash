#
# this is another custom bash library
# 

function my.hello() {
  echo "hello ${1:-world}"
}

export -f my.hello
