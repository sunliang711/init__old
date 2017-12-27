#!/bin/bash
if (($EUID!=0));then
    echo "need root privilege!"
    exit 1
fi
socks5Proxy=
while getopts ":p:" opt;do
    case "$opt" in
        p)
            socks5Proxy="$OPTARG"
            echo "Using socks5 proxy: $socks5Proxy"
            ;;
    esac
done
shift $(($OPTIND-1))

version=${1:-1.8.3}
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
mv go /usr/local
cd /usr/local/bin
for i in $(ls ../go/bin/*);do
    ln -sf $i .
done
cd -
