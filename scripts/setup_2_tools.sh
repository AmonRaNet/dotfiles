#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Tools: editors, display, managers, vm, etc"
    exit
fi

source $DIR/config.sh

set +e
choice=($(whiptail \
  --checklist "Utils setup (AmonRaNet)" 22 90 15 \
  $(install_target vim) \
  $(install_target rofi) \
  $(install_target gnome-tweak-tool) \
  $(install_target indicator-sound-switcher) \
  $(install_target arandr) \
  $(install_target numlockx) \
  $(install_target yad yet-another-dialog) \
  $(install_target dmenu) \
  $(install_target kbdd) \
  $(install_target xautolock) \
  $(install_target notify-osd) \
  $(install_target compton xorg-compositor) \
  $(install_target sysstat) \
  $(install_target chrome) \
  $(install_target default-jre) \
  $(install_target default-jdk) \
  $(install_target meld diff-tool) \
  $(install_target wine) \
  $(install_target gitkraken) \
  $(install_target giteye) \
  $(install_target icdiff color-diff-side-by-side) \
  $(install_target lightshot screenshot-tool) \
  $(install_target scrot screenshot-tool) \
  $(install_target glogg log-reader) \
  $(install_target thunar file-manager) \
  $(install_target caja file-manager) \
  $(install_target zim local-wiki) \
  $(install_target keepassx) \
  $(install_target skype) \
  $(install_target slack) \
  $(install_target kazam screenshot-tool) \
  $(install_target variety) \
  $(install_target remmina) \
  $(install_target gdrive) \
  $(install_target yandexdisk) \
  $(install_target dropbox) \
  $(install_target blueproximity) \
  $(install_target zeal local-docs) \
  $(install_target bat alternative-cat) \
  $(install_target fd alternative-find) \
  $(install_target mosh ssh-mobile-shell) \
  $(install_target dbeaver database-viewer) \
  $(install_target rfid custom-rfid-tools) \
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
        "notify-osd" \
        "sysstat" \
        "default-jre" \
        "default-jdk" \
        "meld" \
        "scrot" \
        "glogg" \
        "caja" \
        "zim" \
        "keepassx" \
        "kazam" \
        "blueproximity" \
        "mosh")
for i in ${simple[@]}
do
   if is_install "$i"; then
       echo_install $INSTALL_TARGET
       sudo apt-get --assume-yes --no-install-recommends install $i
       target_done $INSTALL_TARGET
   fi
done

if is_install "rofi"; then
   echo_install $INSTALL_TARGET
   sudo add-apt-repository -y ppa:jasonpleau/rofi
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install rofi
   rm -fR /tmp/rofi-themes
   git clone https://github.com/DaveDavenport/rofi-themes.git /tmp/rofi-themes
   sudo cp -vR /tmp/rofi-themes/User\ Themes/. /usr/share/rofi/themes/
   rofi-theme-selector
   target_done $INSTALL_TARGET
fi

if is_install "indicator-sound-switcher"; then
   echo_install $INSTALL_TARGET
   sudo add-apt-repository -y ppa:yktooo/ppa
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install indicator-sound-switcher
   target_done $INSTALL_TARGET
fi

if is_install "chrome"; then
   echo_install $INSTALL_TARGET
   wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
   echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
   sudo apt-get -q update
   sudo apt-get install google-chrome-stable
   target_done $INSTALL_TARGET
fi

if is_install "wine"; then
   echo_install $INSTALL_TARGET
   sudo dpkg --add-architecture i386
   wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
   sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ xenial main'
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install winehq-stable
   target_done $INSTALL_TARGET
fi

if is_install "gitkraken"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/gitkraken-amd64.deb https://release.gitkraken.com/linux/gitkraken-amd64.deb
   install_deb "/tmp/gitkraken-amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "giteye"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/giteye-x64.zip https://www.collab.net/sites/default/files/downloads/GitEye-2.1.0-linux.x86_64.zip
   sudo unzip /tmp/giteye-x64.zip -d /opt/giteye
   sudo ln -s /opt/giteye/GitEye /usr/bin/giteye
   target_done $INSTALL_TARGET
fi

if is_install "icdiff"; then
   echo_install $INSTALL_TARGET
   pip install --user git+https://github.com/jeffkaufman/icdiff.git
   git config --global icdiff.options '--highlight --line-numbers'
   target_done $INSTALL_TARGET
fi

if is_install "lightshot"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/setup-lightshot.exe https://app.prntscr.com/build/setup-lightshot.exe
   wine /tmp/setup-lightshot.exe
   target_done $INSTALL_TARGET
fi

if is_install "skype"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/skypeforlinux-x64.deb https://repo.skype.com/latest/skypeforlinux-64.deb
   install_deb "/tmp/skypeforlinux-x64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "slack"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/slack-amd64.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb
   install_deb "/tmp/slack-amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "remmina"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install remmina
   sudo apt-get --assume-yes --no-install-recommends install remmina-plugin-rdp
   sudo apt-get --assume-yes --no-install-recommends install libfreerdp-plugins-standard
   target_done $INSTALL_TARGET
fi

if is_install "variety"; then
   echo_install $INSTALL_TARGET
   sudo add-apt-repository -y ppa:variety/stable
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install variety
   sudo apt-get --assume-yes --no-install-recommends install feh
   target_done $INSTALL_TARGET
fi

if is_install "thunar"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install thunar
   sudo apt-get --assume-yes --no-install-recommends install gnome-icon-theme
   target_done $INSTALL_TARGET
fi

if is_install "gdrive"; then
   echo_install $INSTALL_TARGET

   sudo apt-get --assume-yes --no-install-recommends install inotify-tools

   app_id="$(input_dialog "grive custom client_id" "")"
   secret_id="$(input_dialog "grive custom secret_id" "")"
   build_in_docker $DIR/make_grive.sh "$app_id" "$secret_id"
   build_in_host $DIR/make_grivetools.sh

   msg_dialog "Finish setup and exit setup application to continue!"
   /opt/thefanclub/grive-tools/grive-setup
   target_done $INSTALL_TARGET
fi

if is_install "yandexdisk"; then
   echo_install $INSTALL_TARGET
   sudo sh -c 'echo "deb http://repo.yandex.ru/yandex-disk/deb/ stable main" > /etc/apt/sources.list.d/yandex-disk.list'
   wget http://repo.yandex.ru/yandex-disk/YANDEX-DISK-KEY.GPG -O- | sudo apt-key add -
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install yandex-disk
   sudo add-apt-repository -y ppa:slytomcat/ppa
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install yd-tools
   msg_dialog "Finish setup and exit setup application to continue!"
   yandex-disk-indicator
   target_done $INSTALL_TARGET
fi

if is_install "dropbox"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/dropbox_amd64.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2018.11.28_amd64.deb
   install_deb "/tmp/dropbox_amd64.deb"
   msg_dialog "Finish setup and exit setup application to continue!"
   dropbox start -i
   target_done $INSTALL_TARGET
fi

if is_install "zeal"; then
   echo_install $INSTALL_TARGET
   sudo apt-add-repository -y ppa:zeal-developers/ppa
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install zeal
   target_done $INSTALL_TARGET
fi

if is_install "bat"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/bat_amd64.deb https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb
   install_deb "/tmp/bat_amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "fd"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/fd_amd64.deb https://github.com/sharkdp/fd/releases/download/v7.4.0/fd_7.4.0_amd64.deb
   install_deb "/tmp/fd_amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "dbeaver"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/dbeaver_amd64.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
   install_deb "/tmp/dbeaver_amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "rfid"; then
   echo_install $INSTALL_TARGET
   $DIR/rfid/install
   target_done $INSTALL_TARGET
fi
