#!/bin/bash

this=$(cd $(dirname $BASH_SOURCE) && pwd)
cd $this

user=${SUDO_USER:-$(whoami)}
home=$(eval echo ~$user)


cat<<EOF>$home/.tmux.conf
set -g display-panes-time 3000 #3s
#set-window-option mode-keys vi
set -g mouse on
EOF


