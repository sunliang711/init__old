#!/bin/bash
me="$(cd $(dirname $(realpath $BASH_SOURCE)) && pwd)"
cd "$me"

cat<<EOF >>/tmp/pullInit.log
PWD: $PWD
Time: $(date +%FT%T)
Message:
EOF
git pull >> /tmp/pullInit.log
echo "*************************" >> /tmp/pullInit.log
