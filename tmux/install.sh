#!/bin/bash

this=$(cd $(dirname $BASH_SOURCE) && pwd)
cd $this

user=${SUDO_USER:-$(whoami)}
home=$(eval echo ~$user)


cat<<EOF>$home/.tmux.conf
set-window-option -g mode-keys vi
set -g display-panes-time 10000 #10s

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

set -g mouse on

# not work
# bind-key -T vi-copy 'v' begin-selection
# bind-key -T vi-copy 'y' copy-selection

# works well
bind-key -Tcopy-mode-vi 'v' send -X begin-selection
bind-key -Tcopy-mode-vi 'y' send -X copy-selection

bind k select-pane -U
bind j select-pane -D
bind h select-pane -L
bind l select-pane -R

bind H resize-pane -L 4
bind L resize-pane -R 4
bind J resize-pane -D 4
bind K resize-pane -U 4

bind s source-file ~/.tmux.conf

EOF


