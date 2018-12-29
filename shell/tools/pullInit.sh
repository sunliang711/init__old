#!/bin/bash
logfile=/tmp/pullInit.log
lineLimit=200

currentline=$(wc -l $logfile | awk '{print $1}')
if (($currentline > $lineLimit));then
    tail -$lineLimit $logfile >$logfile.tmp
    mv $logfile.tmp $logfile
fi

case $(uname) in
    Linux)
        realpath=/usr/bin/realpath
        ;;
    Darwin)
        realpath=/usr/local/bin/realpath
        ;;
esac
if [ ! -e $realpath ];then
    echo "Need realpath cmd" >> $logfile
    exit 1
fi

me="$(cd $(dirname $($realpath $BASH_SOURCE)) && pwd)"
cd "$me"

cat<<EOF >>$logfile
BASH_SOURCE: $BASH_SOURCE
realpath: $(/usr/local/bin/realpath $BASH_SOURCE)
dirname: $(dirname $(/usr/local/bin/realpath $BASH_SOURCE))
PWD: $PWD
Time: $(date +%FT%T)
Message:
EOF
git pull >> $logfile
echo "**************************************************" >> $logfile
