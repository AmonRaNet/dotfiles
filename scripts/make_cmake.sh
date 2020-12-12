#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $DIR/config.sh

if [ "$1" = "build" ]; then
    depends="git ca-certificates build-essential libssl-dev checkinstall"
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install $depends
    git clone https://github.com/Kitware/CMake --branch release cmake
    cd cmake
    VERSION=$(echo "$(git describe --tags --always)" | cut -c 2-)
    ./bootstrap
    make -j$(nproc)
    checkinstall \
      --type=debian \
      --maintainer=AmonRaNet \
      --nodoc \
      --pkgname=cmake \
      --pkgversion=$VERSION \
      --default \
      --pakdir=. \
      --instal=no \
      --replaces='cmake'
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "cmake/cmake_*_amd64.deb"
fi
