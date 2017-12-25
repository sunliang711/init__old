#!/bin/bash

case $(uname) in
    Linux)
        #check linux distribution version
        release=$(cat /etc/os-release | grep '^ID' | grep -oP '(?<=ID=).+' | tr -d '"')
        version=$(cat /etc/os-release | grep '^VERSION_ID' | grep -oP '(?<=ID=).+' | tr -d '"')
        echo $release-$version
        ;;
    *)
        exit 1
esac
