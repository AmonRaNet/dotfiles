#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "DevKit: IDE"
    exit
fi

source $DIR/config.sh

set +e
choice=($(whiptail \
  --checklist "Python tools setup (AmonRaNet)" 20 80 1 \
  pycharm "PyCharm" off \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

if is_install "pycharm"; then
   echo_install "pycharm"
   sudo snap install pycharm-community --classic
fi
