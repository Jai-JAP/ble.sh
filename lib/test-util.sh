# source script for ble.sh interactive sessions -*- mode: sh; mode: sh-bash -*-

ble/util/import "$_ble_base/lib/core-test.sh"

# bleopt

(
  # 定義・設定・出力
  ble/test 'bleopt a=1' \
           exit=1
  ble/test 'bleopt a' \
           stdout=
  ble/test 'bleopt a:=2'
  ble/test 'bleopt a' \
           stdout="bleopt a='2'"
  ble/test '[[ $bleopt_a == 2 ]]'
  ble/test "bleopt | grep 'bleopt a='" \
           stdout="bleopt a='2'"
  ble/test 'bleopt a=3'
  ble/test 'bleopt a' \
           stdout="bleopt a='3'"

  # setter
  function bleopt/check:a { value=123; }
  ble/test 'bleopt a=4 && bleopt a'
  stdout="bleopt a='123'"
  function bleopt/check:a { false; }
  ble/test 'bleopt a=5' \
           exit=1
  ble/test 'bleopt a' \
           stdout="bleopt a='123'"

  # 複数引数
  ble/test bleopt f:=10 g:=11
  ble/test bleopt f g \
           stdout="bleopt f='10'${_ble_term_nl}bleopt g='11'"
  ble/test bleopt f=12 g=13
  ble/test bleopt f g \
           stdout="bleopt f='12'${_ble_term_nl}bleopt g='13'"

  # bleopt/declare
  ble/test bleopt/declare -v b 6
  ble/test bleopt b stdout="bleopt b='6'"
  ble/test bleopt/declare -n c 7
  ble/test bleopt c stdout="bleopt c='7'"
  ble/test bleopt d:= e:=
  ble/test bleopt/declare -v d 8
  ble/test bleopt/declare -n e 9
  ble/test bleopt d stdout="bleopt d=''"
  ble/test bleopt e stdout="bleopt e='9'"
)

# ble/test

ble/test ble/util/setexit 0   exit=0
ble/test ble/util/setexit 1   exit=1
ble/test ble/util/setexit 9   exit=9
ble/test ble/util/setexit 128 exit=128
ble/test ble/util/setexit 255 exit=255

#------------------------------------------------------------------------------

## 関数 ble/test/check-ret
##   deprecated
function ble/test/check-ret {
  local f=$1 in=$2 expected=$3 ret
  "$f" "$in" "${@:4}"
  if ! ble/util/assert '[[ $ret == "$expected" ]]'; then
    ble/util/print "command: $f $in" >&2
    ble/util/print 'FAIL: $ret'
    ble/test/diff "$expected" "$ret"
  fi
}

function ble/test:ble/array#pop {
  local arr; eval "arr=($1)"
  ble/array#pop arr
  ret="$ret:(${arr[*]}):${#arr[*]}"
}
ble/test/check-ret ble/test:ble/array#pop '' ':():0'
ble/test/check-ret ble/test:ble/array#pop '1' '1:():0'
ble/test/check-ret ble/test:ble/array#pop '1 2' '2:(1):1'
ble/test/check-ret ble/test:ble/array#pop '0 0 0' '0:(0 0):2'
ble/test/check-ret ble/test:ble/array#pop '1 2 3' '3:(1 2):2'
ble/test/check-ret ble/test:ble/array#pop '" a a " " b b " " c c "' ' c c :( a a   b b ):2'

function ble/test:ble/string#escape {
  ble/test/check-ret ble/string#escape-for-sed-regex '\.[*?+|^$(){}/' '\\\.\[\*?+|\^\$(){}\/'
  ble/test/check-ret ble/string#escape-for-awk-regex '\.[*?+|^$(){}/' '\\\.\[\*\?\+\|\^\$\(\)\{\}\/'
  ble/test/check-ret ble/string#escape-for-extended-regex '\.[*?+|^$(){}/' '\\\.\[\*\?\+\|\^\$\(\)\{\}/'
  ble/test/check-ret ble/string#escape-for-bash-specialchars '[hello] (world) {this,is} <test>' '\[hello\]\ \(world\)\ {this,is}\ \<test\>'
  ble/test/check-ret ble/string#escape-for-bash-specialchars '[hello] (world) {this,is} <test>' '\[hello\]\ \(world\)\ \{this\,is\}\ \<test\>' b
  ble/test/check-ret ble/string#escape-for-bash-specialchars 'a=b:c:d' 'a\=b\:c\:d' c
}

ble/test:ble/string#escape

function ble/test:ble/array#index {
  local needle=${1%%:*} arr
  arr=(${1#*:})
  ble/array#index arr "$needle"
}
ble/test/check-ret ble/test:ble/array#index 'hello:hello world this hello world' 0
ble/test/check-ret ble/test:ble/array#index 'hello:world hep this hello world' 3
ble/test/check-ret ble/test:ble/array#index 'check:hello world this hello world' -1

function ble/test:ble/array#last-index {
  local needle=${1%%:*} arr
  arr=(${1#*:})
  ble/array#last-index arr "$needle"
}
ble/test/check-ret ble/test:ble/array#last-index 'hello:hello world this hello world' 3
ble/test/check-ret ble/test:ble/array#last-index 'hello:world hep this hello world' 3
ble/test/check-ret ble/test:ble/array#last-index 'check:hello world this hello world' -1
