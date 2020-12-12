#! /bin/bash

if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as non-root" 1>&2
   exit 1
fi

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  WHITE="$(tput setaf 7)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  WHITE=""
  BOLD=""
  NORMAL=""
fi

set -e

echo_install() {
    echo "${BLUE}==========================================================${NORMAL}"
    echo "${BOLD}                 $1${NORMAL}"
    echo "${BLUE}==========================================================${NORMAL}"
}

echo_task() {
    echo "${GREEN}${BOLD}--->${NORMAL}$1"
}

mark_done() {
    echo "${GREEN}${BOLD}<DONE>${NORMAL}"
}

mark_skipped() {
    echo "${RED}${BOLD}<SKIPPED>${NORMAL}"
}

INSTALL_TARGET=""
EXPECTED_INSTALL_FILE="$HOME/.config/setup-expected.conf"

install_target() {
   set +e
   grep -Fxq "$1" "$EXPECTED_INSTALL_FILE" > /dev/null
   local result=$?
   set -e
   local target="$1"
   local description="$2"
   if [ "$description" = "" ]; then
      description="$1"
   fi
   if [ $result = 0 ]; then
      echo "$target $description on"
      return 0
   fi
   echo "$target $description off"
   return 1
}

target_done() {
   sed -i '/'"$1"'/d' "$EXPECTED_INSTALL_FILE"
   mark_done
}

is_install() {
   local i
   for i in "${choice[@]}"
   do
     if [ "$i" = "$1" ] || [ "$i" = "\"$1\"" ]; then
        INSTALL_TARGET="$1"
        return
     fi
   done
   INSTALL_TARGET=""
   return 1
}

no_choice_exit() {
    if [ ${#choice[@]} = 0 ]; then
        exit 0
    fi
}

yesno_dialog() {
    set +e
    whiptail  --title "Request" --yesno "$@" 20 60 3>&1 1>&2 2>&3
    local result=$?
    set -e
    if [ $result = 0 ]; then
        return
    fi
    return 1
}

msg_dialog() {
    set +e
    whiptail --title "Message" --msgbox "$@" 8 78
    set -e
}

input_dialog() {
    whiptail --title "Input" --inputbox "$1" 8 78 "$2" 3>&1 1>&2 2>&3
}

app_exists() {
    set +e
    command -v $1 > /dev/null
    local result=$?
    set -e
    return $result
}

test_command() {
    set +e
    echo "Evaluate: $@"
    eval "$@" >/dev/null
    local result=$?
    set -e
    return $result
}

build_in_docker() {
    echo_task "BUILD_IN_DOCKER"
    local make_script=$1
    local build_dir="/tmp/build_in_docker"
    mkdir -p $build_dir
    sudo rm -rf $build_dir/*
    echo ${YELLOW}
    docker run -it \
           -v $make_script:$make_script:ro \
           -v $build_dir:$build_dir:rw \
           -w $build_dir \
           --entrypoint "/bin/bash" \
           ubuntu:$(lsb_release -cs) \
           $make_script build ${@:2}
    sudo chown -R --quiet $USER:$GROUPS $build_dir
    echo ${NORMAL}
    pushd .
    cd $build_dir
    $make_script install
    $make_script config
    popd
}

build_in_host() {
    echo_task "BUILD_IN_HOST"
    local make_script=$1
    local build_dir="/tmp/build_in_host"
    mkdir -p $build_dir
    rm -rf $build_dir/*
    pushd .
    cd $build_dir
    $make_script build ${@:2}
    $make_script install
    $make_script config
    popd
}

install_deb() {
    set +e
    sudo dpkg -i $1
    local result=$?
    set -e
    if [ ! $result = 0 ]; then
        sudo apt-get --assume-yes --no-install-recommends install -f
        sudo dpkg -i $1
    fi
}

is_ubuntu() {
    local ubuntu=$(lsb_release -is)
    if [ "$ubuntu" = "Ubuntu" ]; then
        return
    fi
    return 1
}

is_ubuntu16() {
    local ubuntu=$(lsb_release -cs)
    if [ "$ubuntu" = "xenial" ]; then
        return
    fi
    return 1
}

is_ubuntu18() {
    local ubuntu=$(lsb_release -cs)
    if [ "$ubuntu" = "bionic" ]; then
        return
    fi
    return 1
}

is_ubuntu20() {
    local ubuntu=$(lsb_release -cs)
    if [ "$ubuntu" = "focal" ]; then
        return
    fi
    return 1
}

# Apply sudo for terminal
sudo -v

# Check OS
if ! is_ubuntu; then
    msg_dialog "Only Ubuntu supported!"
    exit 1
fi
