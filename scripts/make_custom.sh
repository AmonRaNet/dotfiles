#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $DIR/config.sh

if [ "$1" = "build" ]; then
    depends="git ca-certificates build-essential pkg-config autoconf automake checkinstall"
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install $depends
 
    echo "============================================="
    echo "===== Build step ("exit" when finished) ====="
    echo "============================================="
    bash
fi

if [ "$1" = "install" ]; then
    echo "============================================="
    echo "===== Install step ("exit" when finished) ====="
    echo "============================================="
    bash
fi
