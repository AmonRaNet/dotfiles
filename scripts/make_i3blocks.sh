#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "build" ]; then
    depends="git ca-certificates build-essential pkg-config autoconf automake checkinstall"
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install $depends
    git clone https://github.com/vivien/i3blocks
    cd i3blocks
    VERSION=$(git describe --tags --always)
    ./autogen.sh
    ./configure
    make -j$(nproc)
    checkinstall \
      --type=debian \
      --maintainer=AmonRaNet \
      --nodoc \
      --pkgname=i3blocks \
      --pkgversion=$VERSION \
      --default \
      --pakdir=. \
      --instal=no
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "i3blocks/i3blocks_*_amd64.deb"
fi
