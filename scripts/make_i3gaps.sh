#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $DIR/config.sh

if [ "$1" = "build" ]; then
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install software-properties-common
    depends="git ca-certificates build-essential
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev
    libxcb-util0-dev libxcb-icccm4-dev libyajl-dev
    libstartup-notification0-dev libxcb-randr0-dev
    libev-dev libxcb-cursor-dev libxcb-xinerama0-dev
    libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
    libxcb-xrm-dev libxcb-shape0-dev
    meson checkinstall"
    if ! is_ubuntu20_or_higher; then
        add-apt-repository -y ppa:aguignard/ppa
    fi
    apt-get -q update
    apt-get --assume-yes --no-install-recommends install $depends
    git clone --branch "4.18.3" https://www.github.com/Airblader/i3 i3gaps
    cd i3gaps
    VERSION=$(git describe --tags --always)
    rm -rf build/
    mkdir -p build && cd build/
    meson ..
    ninja
    checkinstall \
      --type=debian \
      --maintainer=AmonRaNet \
      --nodoc \
      --pkgname=i3gaps \
      --pkgversion=$VERSION \
      --default \
      --pakdir=.. \
      --instal=no \
      --requires='libc6 \(\>= 2.14\),libcairo2 \(\>= 1.14.4\),libev4 \(\>= 1:4.04\),libglib2.0-0 \(\>= 2.12.0\),libpango-1.0-0 \(\>= 1.14.0\),libpangocairo-1.0-0 \(\>= 1.22.0\),libpcre3,libstartup-notification0 \(\>= 0.10\),libxcb-cursor0 \(\>= 0.0.99\),libxcb-icccm4 \(\>= 0.4.1\),libxcb-keysyms1 \(\>= 0.4.0\),libxcb-randr0 \(\>= 1.3\),libxcb-util1 \(\>= 0.4.0\),libxcb-xinerama0,libxcb-xkb1,libxcb-xrm0 \(\>= 0.0.0\),libxcb1 \(\>= 1.6\),libxkbcommon-x11-0 \(\>= 0.5.0\),libxkbcommon0 \(\>= 0.5.0\),libyajl2 \(\>= 2.0.4\),perl,x11-utils' \
      --provides='x-window-manager' \
      --replaces='i3,i3-wm' \
      ninja install
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "i3gaps/i3gaps_*_amd64.deb"
fi
