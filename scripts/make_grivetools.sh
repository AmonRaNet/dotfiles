#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $DIR/config.sh

if [ "$1" = "build" ]; then
    git clone https://github.com/AmonRaNet/grive-tools.git --branch AmonRaNet grive-tools
    cd grive-tools
    ./create_debian_package .
fi

if [ "$1" = "install" ]; then
    source $DIR/config.sh
    install_deb "grive-tools/grive-tools*.deb"
fi
