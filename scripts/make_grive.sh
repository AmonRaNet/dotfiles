#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

is_ubuntu16() {
    local ubuntu=$(lsb_release -cs)
    if [ "$ubuntu" = "xenial" ]; then
        return
    fi
    return 1
}

if [ "$1" = "build" ]; then
    apt-get update
    apt-get --assume-yes --no-install-recommends install lsb-release
    if is_ubuntu16; then
        depends="git ca-certificates build-essential cmake libgcrypt11-dev libyajl-dev \
                 libboost-filesystem1.58-dev libboost-program-options1.58-dev libboost-system1.58-dev libboost-regex1.58-dev libboost-test1.58-dev \
                 libcurl4-openssl-dev libexpat1-dev libcppunit-dev binutils-dev \
                 debhelper zlib1g-dev dpkg-dev pkg-config checkinstall"
        requires='binutils \(\>= 2.26.1\), binutils \(\<\< 2.27\), libboost-filesystem1.58.0, libboost-program-options1.58.0, libboost-regex1.58.0, libboost-system1.58.0, libc6 \(\>= 2.14\), libcurl3 \(\>= 7.16.2\), libgcc1 \(\>= 1:3.0\), libgcrypt20 \(\>= 1.6.1\), libstdc++6 \(\>= 5.2\), libyajl2 \(\>= 2.0.4\)'
    else
        depends="git ca-certificates build-essential cmake libgcrypt11-dev libyajl-dev \
                 libboost-filesystem1.65-dev libboost-program-options1.65-dev libboost-system1.65-dev libboost-regex1.65-dev libboost-test1.65-dev \
                 libcurl4-openssl-dev libexpat1-dev libcppunit-dev binutils-dev \
                 debhelper zlib1g-dev dpkg-dev pkg-config checkinstall"
        requires='libbinutils \(\>= 2.30\), libbinutils \(\<\< 2.30.1\), libboost-filesystem1.65.1, libboost-program-options1.65.1, libboost-regex1.65.1, libboost-system1.65.1, libc6 \(\>= 2.14\), libcurl4 \(\>= 7.16.2\), libgcc1 \(\>= 1:3.0\), libgcrypt20 \(\>= 1.8.0\), libstdc++6 \(\>= 5.2\), libyajl2 \(\>= 2.0.4\)'
    fi
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
      --replaces='grive' \
      --requires="$requires"
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "grive/grive*_amd64.deb"
fi
