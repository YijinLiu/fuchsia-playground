#!/bin/bash

RED='\e[0;31m'
GREEN='\e[0;92m'
YELLOW='\e[0;33m'
NC='\e[0m'
PREFIX=/usr/local
BASEDIR=$(dirname $(readlink -f $0))

usage() {
    echo "Options:
    --layer zircon/garnet/peridot/topaz
    --arch x64/arm64
"
}

OPTS=`getopt -n 'fuchsia.sh' -a -o a:,l: \
             -l arch:,layer: \
             -- "$@"`
rc=$?
if [ $rc != 0 ] ; then
    usage
    exit 1
fi

arch=x64
layer=topaz
eval set -- "$OPTS"
while true; do
    case "$1" in
        -a | --arch )         arch=$2 ; shift 2 ;;
        -l | --layer )        layer=$2 ; shift 2 ;;
        -- ) shift; break ;;
        * ) echo -e "${RED}Invalid option: -$1${NC}" >&2 ; usage ; exit 1 ;;
    esac
done

install_deps() {
    sudo apt update && sudo apt upgrade -y &&
    sudo apt install -y autoconf build-essential ca-certificates coreutils curl git golang \
        libglib2.0-dev libtool libsdl-dev liblz4-tool make python texinfo unzip wget
    rc=$?
    if [ $rc != 0 ]; then
        echo -e "${RED}Failed to install fuchsia dependencies!${NC}"
        return 1
    fi
}

download_src() {
    if [ -d fuchsia ]; then
        return 0
    fi
    # The fetched script will
    # - create "fuchsia" directory if it does not exist,
    # - download "jiri" command to "fuchsia/.jiri_root/bin"
    curl -s "https://fuchsia.googlesource.com/jiri/+/master/scripts/bootstrap_jiri?format=TEXT" | \
        base64 --decode | bash -s fuchsia
    rc=$?
    if [ $rc != 0 ]; then
        echo -e "${RED}Failed to download jiri!${NC}"
        return 1
    fi
    cd fuchsia
    .jiri_root/bin/jiri init -analytics-opt=false "$(pwd)" &&
    .jiri_root/bin/jiri import -name="${layer}" "manifest/${layer}" \
        "https://fuchsia.googlesource.com/${layer}" &&
    .jiri_root/bin/jiri update -hook-timeout=10
    rc=$?
    if [ $rc != 0 ]; then
        echo -e "${RED}Failed to download fuchsia source code!${NC}"
        return 1
    fi
    cd ..
}

build() {
    cd fuchsia
    .jiri_root/bin/fx set ${arch} &&
    .jiri_root/bin/fx full-build
    rc=$?
    if [ $rc != 0 ]; then
        echo -e "${RED}Failed to build fuchsia!${NC}"
        return 1
    fi
    cd ..
}

install_deps &&
download_src &&
build
