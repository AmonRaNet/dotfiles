#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "build" ]; then
    depends="git ca-certificates build-essential cmake libgcrypt11-dev libyajl-dev \
             libboost-all-dev libcurl4-openssl-dev libexpat1-dev libcppunit-dev binutils-dev \
             debhelper zlib1g-dev dpkg-dev pkg-config checkinstall"
    apt-get update
    apt-get --assume-yes --no-install-recommends install $depends
    git clone https://github.com/AmonRaNet/grive2.git --branch AmonRaNet grive
    cd grive
    VERSION=$(echo "$(git describe --tags --always)" | cut -c 2-)
    CMAKE_ARG="-DGRIVE_VERSION=$VERSION"
    if [ -n "$2" ]; then
        CMAKE_ARG="$CMAKE_ARG -DAPP_ID:STRING=$2"
    fi
    if [ -n "$3" ]; then
        CMAKE_ARG="$CMAKE_ARG -DAPP_SECRET:STRING=$3"
    fi
    echo "$CMAKE_ARG"
    cmake $CMAKE_ARG
    make -j$(nproc)
    checkinstall \
      --type=debian \
      --maintainer=AmonRaNet \
      --nodoc \
      --pkgname=grive \
      --pkgversion=$VERSION \
      --default \
      --pakdir=. \
      --instal=no \
      --replaces='grive'
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "grive/grive*_amd64.deb"
fi
