#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
if [ -e /etc/shell-header.sh ];then
    source /etc/shell-header.sh
else
    (cd /tmp && wget -q "$shellHeaderLink") && source /tmp/shell-header.sh
fi
# write your code below

if [ -z $GO111MODULE ];then
    echo "GO111MODULE not set"
    exit 1
fi

if [ -z "$GOPROXY" ];then
    echo "GOPROXY not set"
    exit 1
fi
go get -u -v github.com/ramya-rao-a/go-outline
go get -u -v github.com/acroca/go-symbols
go get -u -v github.com/mdempsky/gocode
go get -u -v github.com/rogpeppe/godef
go get -u -v golang.org/x/tools/cmd/godoc
go get -u -v github.com/zmb3/gogetdoc
go get -u -v golang.org/x/lint/golint
go get -u -v github.com/fatih/gomodifytags
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v sourcegraph.com/sqs/goreturns
go get -u -v golang.org/x/tools/cmd/goimports
go get -u -v github.com/cweill/gotests/...
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v github.com/josharian/impl
go get -u -v github.com/haya14busa/goplay/cmd/goplay
go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
go get -u -v github.com/alecthomas/gometalinter
go get -u -v golang.org/x/tools/cmd/gopls
go get -u -v github.com/go-delve/delve
go get -u -v github.com/jstemmer/gotags
go get -u -v github.com/fatih/motion
go get -u -v github.comkisielk/errcheck
go get -u -v github.comgolangci/golang-ci-lint
go get -u -v github.comkoron/iferr
go get -u -v github.comklauspost/asmfmt/cmd/asmfmt
go get -u -v github.comalecthomas/gometalinkter
go get -u -v github.com/stamblerre/gocode
go get -u -v github.com/mdempsky/gocode
go get -u -v github.com/go-delve/delve/cmd/dlv
go get -u -v github.com/golangci/golangci-lint/cmd/golangci-lint
go get -u -v honnef.co/go/tools/cmd/keyify

