#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $DIR/config.sh

if [ "$1" = "build" ]; then
    depends="git ca-certificates checkinstall"
    requires='python3, python3-pyinotify, python3-pyasyncore, grive \(\>= 0.3\)'
    branch="master"
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install $depends
    git clone --branch $branch https://github.com/AmonRaNet/grive-tools.git
    cd grive-tools
    VERSION=$(git describe --tags --always)
    checkinstall \
        --type=debian \
        --maintainer=AmonRaNet \
        --nodoc \
        --pkgname=grive-tools \
        --pkgversion=$VERSION \
        --arch=all \
        --default \
        --pakdir=. \
        --instal=no \
        --backup=no \
        --requires="$requires" \
        make install
fi

if [ "$1" = "install" ]; then
    install_deb "grive-tools/grive-tools*.deb"
fi
