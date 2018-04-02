#!/bin/sh
if ! command -v pip >/dev/null 2>&1;then
    echo "Not find pip"
    exit 1
fi
if [ ! -d ~/.pip ];then
      mkdir ~/.pip
fi
cat>~/.pip/pip.conf<<EOF
[global]
trusted-host = pypi.tuna.tsinghua.edu.cn
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
