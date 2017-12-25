#!/bin/bash

case $(uname) in
    Linux)
        versionFile=/etc/os-release
        if [[ ! -e "$versionFile" ]];then
            exit 1
        fi
        #check linux distribution version
        release=$(cat "$versionFile" | grep '^ID' | grep -oP '(?<=ID=).+' | tr -d '"')
        version=$(cat "$versionFile" | grep '^VERSION_ID' | grep -oP '(?<=ID=).+' | tr -d '"')
        echo $release-$version
        ;;
    Darwin)
        echo mac
        ;;
    *)
        exit 1
        ;;
esac
