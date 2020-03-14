#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
me="$(cd $(dirname $rpath) && pwd)"
cd "$me"


cp coc-settings.json $root

echo "Install cmake-language-server..."
if ! command -v cmake-language-server >/dev/null 2>&1;then
    pip3 install cmake-language-server >/dev/null 2>&1 || { echo "Please use pip to install cmake-language-server"; }
fi


echo "Install bash-language-server..."
if ! command -v bash-language-server >/dev/null 2>&1;then
    npm i -g bash-language-server >/dev/null 2>&1 || { echo "Please use npm to install bash-language-server"; }
fi

echo "Issue command: "brew install llvm" to install clangd on MacOS and Linux if you want to use cland as language server"
