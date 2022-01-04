#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Base: python, i3, shells"
    exit
fi

source $DIR/config.sh

set +e
choice=($(whiptail \
  --checklist "General tools setup (AmonRaNet)" 20 80 15 \
  $(install_target python) \
  $(install_target docker) \
  $(install_target i3) \
  $(install_target i3bloks) \
  $(install_target i3gaps) \
  $(install_target terminator) \
  $(install_target gnome-terminal) \
  $(install_target awesome-fonts) \
  $(install_target powerline-fonts) \
  $(install_target fish-shell) \
  $(install_target zsh-shell) \
  $(install_target fzf fuzzy-finder) \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

set_default_terminal() {
  local TERMINAL=$(which $1)
  sudo gsettings set org.gnome.desktop.default-applications.terminal exec ''$TERMINAL''
  sudo gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $TERMINAL 0
  sudo update-alternatives --set x-terminal-emulator $TERMINAL
}

set_default_shell() {
  local SHELL=$(which $1)
  sudo echo $SHELL | sudo tee -a /etc/shells
  sudo chsh -s $SHELL
}

if is_install "python"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install python
   sudo apt-get --assume-yes --no-install-recommends install python3
   sudo apt-get --assume-yes --no-install-recommends install python-pip
   sudo apt-get --assume-yes --no-install-recommends install python3-pip
   sudo bash -c "pip install --upgrade pip"
   sudo bash -c "pip3 install --upgrade pip"
   target_done $INSTALL_TARGET
fi

if is_install "docker"; then
   echo_install $INSTALL_TARGET
   wget -q -O - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   sudo apt-get update
   sudo apt-get --assume-yes --no-install-recommends --allow-unauthenticated install docker-ce
   if [[ "$(groups)" != *"docker"* ]]; then
        sudo usermod -a -G docker $USER
        msg_dialog "User added to docker group. Please logout and login again to continue"
        target_done $INSTALL_TARGET
        exit 1
   fi
   target_done $INSTALL_TARGET
fi

if is_install "i3"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install i3
   sudo apt-get --assume-yes --no-install-recommends install i3status
   sudo apt-get --assume-yes --no-install-recommends install i3lock
   target_done $INSTALL_TARGET
fi

if is_install "i3gaps"; then
   echo_install $INSTALL_TARGET
   build_in_docker $DIR/make_i3gaps.sh
   sudo apt-get --assume-yes --no-install-recommends install i3status
   sudo apt-get --assume-yes --no-install-recommends install i3lock
   target_done $INSTALL_TARGET
fi

if is_install "i3bloks"; then
   echo_install $INSTALL_TARGET
   build_in_docker $DIR/make_i3blocks.sh
   target_done $INSTALL_TARGET
fi

if is_install "terminator"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install terminator
   if yesno_dialog "$INSTALL_TARGET as default?"; then
       set_default_terminal terminator
   fi
   target_done $INSTALL_TARGET
fi

if is_install "gnome-terminal"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install gnome-terminal
   if yesno_dialog "$INSTALL_TARGET as default?"; then
     set_default_terminal gnome-terminal
   fi
   target_done $INSTALL_TARGET
fi

if is_install "awesome-fonts"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install fontconfig
   sudo apt-get --assume-yes --no-install-recommends install fonts-font-awesome
   wget -N -O /tmp/awesome-fonts.zip https://use.fontawesome.com/releases/v5.5.0/fontawesome-free-5.5.0-desktop.zip
   unzip -o /tmp/awesome-fonts.zip 'fontawesome-free-5.5.0-desktop/otfs/*' -d /tmp/awesome-fonts
   font_dir="/usr/share/fonts/opentype/font-awesome/"
   sudo mkdir -p $font_dir
   sudo cp -vR /tmp/awesome-fonts/fontawesome-free-5.5.0-desktop/otfs/* $font_dir
   sudo fc-cache -f "$font_dir"
   target_done $INSTALL_TARGET
fi

if is_install "powerline-fonts"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install fontconfig
   wget -N -O /tmp/powerline-fonts.zip https://codeload.github.com/powerline/fonts/zip/master
   unzip -o /tmp/powerline-fonts.zip -d /tmp/powerline-fonts
   bash /tmp/powerline-fonts/fonts-master/install.sh
   target_done $INSTALL_TARGET
fi

if is_install "fish-shell"; then
   echo_install $INSTALL_TARGET
   #clean
   sudo rm -rf ~/.local/share/omf
   sudo rm -rf ~/.config/omf
   sudo rm -f ~/.config/fish/conf.d/omf.fish
   sudo rm -f ~/.config/fish/functions/fish_prompt.fish
   #fish
   sudo apt-add-repository -y ppa:fish-shell/release-2
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install fish fish-common
   if yesno_dialog "$INSTALL_TARGET as default?"; then
       set_default_shell fish
   fi
   fish -c "echo 'Create fish config'"
   source-auto enable fish
   #oh-my-fish
   wget --no-check-certificate -N -O /tmp/omf-install.fish https://get.oh-my.fish
   fish /tmp/omf-install.fish --noninteractive --path=~/.local/share/omf --config=~/.config/omf
   #oh-my-fish (plugins)
   fish -c "omf install bass"
   fish -c "omf install bobthefish"
   #custom settings
   source-auto script fish _omf_params "# omf params
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts no
set -g theme_avoid_ambiguous_glyphs yes
set -g theme_show_exit_status yes
set -g theme_git_worktree_support no
set -g theme_display_git_master_branch yes
set -g theme_display_docker_machine yes
set -g theme_display_virtualenv yes
"
   target_done $INSTALL_TARGET
fi

if is_install "zsh-shell"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install zsh
   if yesno_dialog "$INSTALL_TARGET as default?"; then
     set_default_shell zsh
   fi
   #oh-my-z
   ZSH=${ZSH:-~/.oh-my-zsh}
   ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
   sudo rm -f ~/.zshrc
   sudo rm -fR $ZSH
   sudo rm -fR $ZSH_CUSTOM
   (
    export SHELL="/bin/zsh";# hack - prevent question "zsh as default shell?"
    msg_dialog "Type \"exit\" when zsh shell started to continue!"
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)";
   )
   wget -N -O ~/.oh-my-zsh/themes/cobalt2.zsh-theme https://raw.github.com/wesbos/Cobalt2-iterm/master/cobalt2.zsh-theme
   install_plugin () {
      target=$ZSH_CUSTOM/plugins/$1
      rm -rf $target
      git clone $2 $target
   }
   #oh-my-z custom plugins
   install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
   install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
   #hack - replace .zshrc by custom and manage omz load with source-auto
   echo "#OMZ enabled and managed by source-auto" > ~/.zshrc
   source-auto enable zsh
   source-auto script zsh _omz_theme "# omz theme
ZSH_THEME=cobalt2"
   source-auto script zsh _omz_params "# omz params
DISABLE_AUTO_UPDATE=true
DISABLE_UNTRACKED_FILES_DIRTY=true
HIST_STAMPS=\"mm/dd/yyyy\""
   source-auto script zsh _omz_plugins "# omz plugins
plugins=(
git
dircycle
dirhistory
history
history-substring-search
zsh-syntax-highlighting
zsh-autosuggestions)"
   source-auto script zsh _omz_zstart "# omz start script
export ZSH=\"$ZSH\"
export ZSH_CUSTOM=\"$ZSH_CUSTOM\"
source \"$ZSH/oh-my-zsh.sh\""
   target_done $INSTALL_TARGET
fi

if is_install "fzf"; then
   echo_install $INSTALL_TARGET
   target=~/.fzf
   rm -rf $target
   git clone --depth 1 https://github.com/junegunn/fzf.git $target
   $target/install
   target_done $INSTALL_TARGET
fi
