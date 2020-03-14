#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
me="$(cd $(dirname $rpath) && pwd)"
cd "$me"

echo "Install go binaries..."
$VIM -c GoInstallBinaries -c qall

