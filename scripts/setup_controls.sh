#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Utils: git, vim, atom, java, wine, etc"
    exit
fi

source $DIR/config.sh

set +e
choice=($(whiptail \
  --checklist "Utils setup (AmonRaNet)" 22 90 15 \
  vim "vim" off \
  rofi "window/application rofi" off \
  gnome-tweak-tool "settings GNOME" off \
  indicator-sound-switcher "sound sources" off \
  arandr "display manager" off \
  numlockx "numlock enabler" off \
  yad "YAD (yet another dialog)" off \
  dmenu "application manager (default in i3)" off\
  kbdd "per window layout using XKB" off \
  xautolock "auto-lock tool" off \
  compton "compositor for Xorg" off \
  sysstat "system statistic (like iostat)" off \
  atom "atom" off \
  atompackages "default atom packages (nuclide,build,lint,etc)" off \
  chrome "google-chrome" off \
  default-jre "java run time" off \
  default-jdk "java developmnet kit" off \
  wine "windows emulator" off \
  gitkraken "git gui(not-free)" off \
  giteye "git gui(free)" off \
  lightshot "screenshot manager(over wine)" off \
  scrot "screenshot CLI" off \
  glogg "log file viewer" off \
  thunar "file manager" off \
  caja "file manager(Mate)" off \
  zim "desktop wiki" off \
  keepassx "pass storage" off \
  skype "skype" off \
  slack "slack" off \
  kazam "screencast and screenshot" off \
  variety "wallpaper manager" off \
  remmina "remote desktop client" off \
  gdrive "GDrive client" off \
  yandexdisk "Yandex Disk client" off \
  dropbox "Dropbox client" off \
  blueproximity "Bluetooth locker" off \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

simple=("vim" \
        "gnome-tweak-tool" \
        "arandr" \
        "numlockx" \
        "yad" \
        "dmenu" \
        "kbdd" \
        "xautolock" \
        "compton" \
        "sysstat" \
        "default-jre" \
        "default-jdk" \
        "scrot" \
        "glogg" \
        "thunar" \
        "caja" \
        "zim" \
        "keepassx" \
        "kazam" \
        "blueproximity")
for i in ${simple[@]}
do
   if is_install "$i"; then
       echo_install "$i"
       sudo apt-get --assume-yes --no-install-recommends install $i
   fi
done

if is_install "rofi"; then
   echo_install "rofi"
   sudo add-apt-repository -y ppa:jasonpleau/rofi
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install rofi
   rm -fR /tmp/rofi-themes
   git clone https://github.com/DaveDavenport/rofi-themes.git /tmp/rofi-themes
   sudo cp -vR /tmp/rofi-themes/User\ Themes/. /usr/share/rofi/themes/
   rofi-theme-selector
fi

if is_install "indicator-sound-switcher"; then
   echo_install "indicator-sound-switcher"
   sudo add-apt-repository -y ppa:yktooo/ppa
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install indicator-sound-switcher
fi

if is_install "chrome"; then
   echo_install "chrome"
   wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
   echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
   sudo apt-get -q update
   sudo apt-get install google-chrome-stable
fi

if is_install "atom"; then
   echo_install "atom"
   wget -N -O /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.32.2/atom-amd64.deb
   install_deb "/tmp/atom-amd64.deb"
fi

if is_install "atompackages"; then
   echo_install "atompackages"
   apm install nuclide
   apm install language-cpp14
   apm install language-cmake
   apm install language-qtpro
   apm install autocomplete-cmake
   apm install autocomplete-clang
   apm install linter-ui-default
   apm install build-cmake
   apm install build-python
   apm install sublime-style-column-selection
   sudo pip3 install pycodestyle
   sudo pip3 install flake8
fi

if is_install "wine"; then
   echo_install "wine"
   sudo dpkg --add-architecture i386
   wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
   sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ xenial main'
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install winehq-stable
fi

if is_install "gitkraken"; then
   echo_install "gitkraken"
   wget -N -O /tmp/gitkraken-amd64.deb https://release.gitkraken.com/linux/gitkraken-amd64.deb
   install_deb "/tmp/gitkraken-amd64.deb"
fi

if is_install "giteye"; then
   echo_install "giteye"
   wget -N -O /tmp/giteye-x64.zip https://www.collab.net/sites/default/files/downloads/GitEye-2.1.0-linux.x86_64.zip
   sudo unzip /tmp/giteye-x64.zip -d /opt/giteye
   sudo ln -s /opt/giteye/GitEye /usr/bin/giteye
fi

if is_install "lightshot"; then
   echo_install "lightshot"
   wget -N -O /tmp/setup-lightshot.exe https://app.prntscr.com/build/setup-lightshot.exe
   wine /tmp/setup-lightshot.exe
fi

if is_install "skype"; then
   echo_install "skype"
   wget -N -O /tmp/skypeforlinux-x64.deb https://repo.skype.com/latest/skypeforlinux-64.deb
   install_deb "/tmp/skypeforlinux-x64.deb"
fi

if is_install "slack"; then
   echo_install "slack"
   wget -N -O /tmp/slack-amd64.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb
   install_deb "/tmp/slack-amd64.deb"
fi

if is_install "remmina"; then
   echo_install "remmina"
   sudo apt-get --assume-yes --no-install-recommends install remmina
   sudo apt-get --assume-yes --no-install-recommends install remmina-plugin-rdp
   sudo apt-get --assume-yes --no-install-recommends install libfreerdp-plugins-standard
fi

if is_install "variety"; then
   echo_install "variety"
   sudo apt-get --assume-yes --no-install-recommends install variety
   sudo apt-get --assume-yes --no-install-recommends install feh
fi

if is_install "gdrive"; then
   echo_install "gdrive"
   sudo add-apt-repository -y ppa:nilarimogard/webupd8
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install grive
   wget -N -O /tmp/grive-tools.deb https://launchpad.net/~thefanclub/+archive/ubuntu/grive-tools/+files/grive-tools_1.15_all.deb
   install_deb "/tmp/grive-tools.deb"
   msg_dialog "Finish setup and exit setup application to continue!"
   /opt/thefanclub/grive-tools/grive-setup
fi

if is_install "yandexdisk"; then
   echo_install "yandexdisk"
   sudo sh -c 'echo "deb http://repo.yandex.ru/yandex-disk/deb/ stable main" > /etc/apt/sources.list.d/yandex-disk.list'
   wget http://repo.yandex.ru/yandex-disk/YANDEX-DISK-KEY.GPG -O- | sudo apt-key add -
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install yandex-disk
   sudo add-apt-repository -y ppa:slytomcat/ppa
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install yd-tools
   msg_dialog "Finish setup and exit setup application to continue!"
   yandex-disk-indicator
fi

if is_install "dropbox"; then
   echo_install "dropbox"
   wget -N -O /tmp/dropbox_amd64.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2018.11.28_amd64.deb
   install_deb "/tmp/dropbox_amd64.deb"
   msg_dialog "Finish setup and exit setup application to continue!"
   dropbox start -i
fi
