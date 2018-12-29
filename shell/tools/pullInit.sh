#!/bin/bash
me="$(cd $(dirname $BASH_SOURCE) && pwd)"
cd "$me"
git pull
