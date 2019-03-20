#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "DevKit: SDK, IDE"
    exit
fi

source $DIR/config.sh

set +e
choice=($(whiptail \
  --checklist "Android tools setup (AmonRaNet)" 20 80 2 \
  androidstudio "Android Studio" off \
  androidtools "Android commmand line tools" off \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

if is_install "androidstudio"; then
   echo_install "androidstudio"
   wget -N -O /tmp/android-studio.zip https://dl.google.com/dl/android/studio/ide-zips/3.3.2.0/android-studio-ide-182.5314842-linux.zip
   sudo unzip /tmp/android-studio.zip -d /opt/android-studio
   sudo chmod +x /opt/android-studio/studio.sh
   sudo ln -s /opt/android-studio/studio.sh /usr/bin/android-studio
   sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
fi

if is_install "androidtools"; then
   echo_install "androidtools"
   wget -N -O /tmp/android-sdktools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
   sudo unzip /tmp/android-sdktools.zip -d /opt/android-sdk
   sudo ln -s /opt/android-sdk/tools/bin/sdkmanager /usr/bin/sdkmanager
   sudo ln -s /opt/android-sdk/tools/bin/avdmanager /usr/bin/avdmanager
fi
