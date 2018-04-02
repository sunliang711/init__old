#!/bin/bash

make(){
    if [[ ! -f /etc/os-release ]];then
        echo "No file /etc/os-release!" 1>&2
        exit 1
    fi
    #check id
    id=$(grep '^ID' /etc/os-release |grep -oP '(?<=ID=)[^=]+')
    if [[ "$id" != "ubuntu" ]] ;then
        echo "Not ubuntu" 1>&2
        exit 1
    fi
    declare -A release2codename
    release2codename=(
        ["10.04"]=lucid
        ["10.10"]=maverick
        ["11.04"]=natty
        ["11.10"]=oneiric
        ["12.04"]=precise
        ["12.10"]=quantal
        ["13.04"]=raring
        ["13.10"]=saucy
        ["14.04"]=trusty
        ["14.10"]=utopic
        ["15.04"]=vivid
        ["15.10"]=wily
        ["16.04"]=xenial
        ["16.10"]=yakkety
        ["17.04"]=zesty
        ["17.10"]=artful
        )
    codename=$(grep -oP '(?<=DISTRIB_CODENAME=)[^=]+' /etc/lsb-release)
    #if cannot find codename,then use find release to find it
    if [[ -z "$codename" ]];then
        release=$(grep -oP '(?<=DISTRIB_RELEASE=)[^=]+' /etc/lsb-release)
        codename="${release2codename[$release]}"
    fi

    url=${1:-"http://mirrors.163.com/ubuntu/"}
    sourcefile="/etc/apt/sources.list"
    #backup
    cp "${sourcefile}" "${sourcefile}.backup"
    type=(security updates proposed backports)
    echo "deb $url $codename main restricted universe multiverse" > "${sourcefile}"
    echo "deb-src $url $codename main restricted universe multiverse" >> "${sourcefile}"
    for t in "${type[@]}";do
        echo "deb $url $codename-$t main restricted universe multiverse" >> "${sourcefile}"
        echo "deb-src $url $codename-$t main restricted universe multiverse" >> "${sourcefile}"
    done
}
make
echo "Run \"apt-get update\" to update source list"
