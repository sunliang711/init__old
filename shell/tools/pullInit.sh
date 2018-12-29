#!/bin/bash
me="$(cd $(dirname $(realpath $BASH_SOURCE)) && pwd)"
cd "$me"

logfile=/tmp/pullInit.log
lineLimit=200


currentline=$(wc -l $logfile | awk '{print $1}')
if (($currentline > $lineLimit));then
    tail -$lineLimit $logfile >$logfile.tmp
    mv $logfile.tmp $logfile
fi

cat<<EOF >>$logfile
PWD: $PWD
Time: $(date +%FT%T)
Message:
EOF
git pull >> $logfile
echo "**************************************************" >> $logfile
