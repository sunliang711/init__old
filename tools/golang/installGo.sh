#!/bin/bash
if (($EUID!=0));then
    echo "need root privilege!"
    exit 1
fi

usage(){
    cat<<EOF
Usage: $(basename $0) [option] [version: 1.13.7] [os: linux] [arch: amd64]

option:
    -p     <socks5 proxy>

EOF
    exit 1
}

socks5Proxy=
while getopts ":p:h" opt;do
    case "$opt" in
        p)
            socks5Proxy="$OPTARG"
            echo "Using socks5 proxy: $socks5Proxy"
            ;;
        h)
            usage
            ;;
    esac
done
shift $(($OPTIND-1))

version=${1:-1.13.7}
os=${2:-linux}
arch=${3:-amd64}
echo "Installing golang version: ${version} on ${os}-${arch} in /usr/local"

cd /tmp
echo "Download golang..."
if [ -n "$socks5Proxy" ];then
    curl --socks5 "$socks5Proxy" -fLO https://storage.googleapis.com/golang/go${version}.${os}-${arch}.tar.gz || { echo "Download golang failed!";exit 1; }
else
    curl -fLO https://storage.googleapis.com/golang/go${version}.${os}-${arch}.tar.gz || { echo "Download golang failed!";exit 1; }
fi
echo "Extract golang..."
tar xf go${version}.${os}-${arch}.tar.gz
if [ -d /usr/local/go ];then
    echo "remove old /usr/local/go ..."
    rm -rf /usr/local/go
fi
mv go /usr/local
cd /usr/local/bin
for i in $(ls ../go/bin/*);do
    ln -sf $i .
done
cd -
