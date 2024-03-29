#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "DevKit: compilers, SDK, IDE"
    exit
fi

source $DIR/config.sh

qtcreator_version=4.11
qtcreator_build=0
qtcreator_spellcheck_version=2.0.5
qtcreator_spellcheck_libhunspell_version=1.7
libhunspell_version=1.7-0

gcc_version=8
clang_version=15

set +e
choice=($(whiptail \
  --checklist "C++ tools setup (AmonRaNet)" 20 80 15 \
  $(install_target cmake) \
  $(install_target ninja) \
  $(install_target bazel) \
  $(install_target gcc v-$gcc_version) \
  $(install_target clang v-$clang_version) \
  $(install_target ccache) \
  $(install_target pre-commit) \
  $(install_target icdiff) \
  $(install_target vim vim-code-completion) \
  $(install_target qtframework) \
  $(install_target qtcreator v-$qtcreator_version) \
  $(install_target qtspellcheck v-$qtcreator_spellcheck_version) \
  $(install_target code visual-studio-code) \
  $(install_target atom) \
  $(install_target atompackages custom) \
  $(install_target pycharm) \
  $(install_target androidstudio) \
  $(install_target androidtools) \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

if is_install "ninja"; then
    echo_install $INSTALL_TARGET
    sudo apt-get --assume-yes --no-install-recommends install ninja-build
    target_done $INSTALL_TARGET
fi

if is_install "gcc"; then
    echo_install $INSTALL_TARGET
    if is_ubuntu16; then
        sudo add-apt-repository ppa:jonathonf/gcc
    fi
    sudo apt-get -q update
    sudo apt-get --assume-yes --no-install-recommends install gcc-${gcc_version} g++-${gcc_version}
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_version} 1000
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${gcc_version} 1000
    sudo update-alternatives --config gcc
    sudo update-alternatives --config g++
    target_done $INSTALL_TARGET
fi

if is_install "clang"; then
    echo_install $INSTALL_TARGET
    ubuntu=$(lsb_release -cs)
    echo -e "deb http://apt.llvm.org/${ubuntu}/ llvm-toolchain-${ubuntu} main \n \
          deb-src http://apt.llvm.org/${ubuntu}/ llvm-toolchain-${ubuntu} main \n \
          deb http://apt.llvm.org/${ubuntu}/ llvm-toolchain-${ubuntu}-${clang_version} main \n \
          deb-src http://apt.llvm.org/${ubuntu}/ llvm-toolchain-${ubuntu}-${clang_version} main \n \
          " |  sudo tee /etc/apt/sources.list.d/llvm.list > /dev/null
    wget -q -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
    sudo apt-get -q update

    sudo apt-get --assume-yes --no-install-recommends install clang-$clang_version
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$clang_version 1000
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$clang_version 1000
    sudo update-alternatives --config clang
    sudo update-alternatives --config clang++

    sudo apt-get --assume-yes --no-install-recommends install clang-format-$clang_version
    sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-$clang_version 1000
    sudo update-alternatives --config clang-format

    sudo apt-get --assume-yes --no-install-recommends install clang-tidy-$clang_version
    sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-$clang_version 1000
    sudo update-alternatives --config clang-tidy

    target_done $INSTALL_TARGET
fi

if is_install "ccache"; then
    echo_install $INSTALL_TARGET
    sudo apt-get --assume-yes --no-install-recommends install ccache
    sudo /usr/sbin/update-ccache-symlinks
    ccache --max-size=50G
    source-auto script bash ccache "export PATH=\"/usr/lib/ccache:\$PATH\""
    source-auto script fish ccache "set -gx PATH /usr/lib/ccache \$PATH"
    source-auto script zsh  ccache "export PATH=\"/usr/lib/ccache:\$PATH\""
    target_done $INSTALL_TARGET
fi

if is_install "pre-commit"; then
   echo_install $INSTALL_TARGET
   pip install pre-commit
fi

if is_install "icdiff"; then
   echo_install $INSTALL_TARGET
   pip install icdiff
fi

if is_install "cmake"; then
   echo_install $INSTALL_TARGET
   build_in_docker $DIR/make_cmake.sh
   target_done $INSTALL_TARGET
fi

if is_install "bazel"; then
   echo_install $INSTALL_TARGET
   wget -q https://bazel.build/bazel-release.pub.gpg -O- | sudo apt-key add -
   sudo add-apt-repository -y "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8"
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install bazel
   target_done $INSTALL_TARGET
fi

if is_install "vim"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install python3-dev
   sudo rm -fR ~/.vim/pack/amonranet/start/YouCompleteMe
   git clone https://github.com/ycm-core/YouCompleteMe.git ~/.vim/pack/amonranet/start/YouCompleteMe
   pushd .
   cd ~/.vim/pack/amonranet/start/YouCompleteMe
   git submodule update --init --recursive
   python3 install.py --clangd-completer
   popd
   target_done $INSTALL_TARGET
fi

if is_install "qtframework"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/qt-x64-online.run http://ftp.fau.de/qtproject/official_releases/online_installers/qt-unified-linux-x64-online.run
   sudo chmod +x /tmp/qt-x64-online.run
   /tmp/qt-x64-online.run
   if yesno_dialog "Install libgl-mesa?"; then
       sudo apt-get --assume-yes --no-install-recommends install libgl1-mesa-dev
   fi
   target_done $INSTALL_TARGET
fi

if is_install "qtcreator"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/qt-x64-creator.run http://ftp.fau.de/qtproject/official_releases/qtcreator/$qtcreator_version/$qtcreator_version.$qtcreator_build/qt-creator-opensource-linux-x86_64-$qtcreator_version.$qtcreator_build.run
   sudo chmod +x /tmp/qt-x64-creator.run
   sudo /tmp/qt-x64-creator.run
   target_done $INSTALL_TARGET
fi

if is_install "qtspellcheck"; then
   echo_install $INSTALL_TARGET
   sudo apt-get --assume-yes --no-install-recommends install libhunspell-${libhunspell_version}
   qtcreator_dir=$(input_dialog "QtCreator directory" "/opt/qtcreator-$qtcreator_version.$qtcreator_build")
   wget -N -O /tmp/qt-x64-spellcheck.tar.gz https://github.com/CJCombrink/SpellChecker-Plugin/releases/download/v$qtcreator_spellcheck_version/SpellChecker-Plugin_v${qtcreator_spellcheck_version}_Hunspell_v${qtcreator_spellcheck_libhunspell_version}_static_x64.tar.gz
   sudo tar -xzvf /tmp/qt-x64-spellcheck.tar.gz --directory $qtcreator_dir --strip-components 1
   if yesno_dialog "Use default dictionary package?"; then
       sudo apt-get --assume-yes --no-install-recommends install hunspell-en-gb
       msg_dialog "Select and apply dictionary (from /usr/share/hunspell) in QtCreator (Menu->Tools->Options->Spell Checker)."
   else
       nohup xdg-open https://sourceforge.net/projects/wordlist/files/speller/2018.04.16/hunspell-en_US-2018.04.16.zip >/dev/null 2>&1
       msg_dialog "Please download dictionary, unpack and apply it in QtCreator (Menu->Tools->Options->Spell Checker)"
   fi
   target_done $INSTALL_TARGET
fi

if is_install "code"; then
   echo_install $INSTALL_TARGET
   wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
   sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install code
   target_done $INSTALL_TARGET
fi

if is_install "atom"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.32.2/atom-amd64.deb
   install_deb "/tmp/atom-amd64.deb"
   target_done $INSTALL_TARGET
fi

if is_install "atompackages"; then
   echo_install $INSTALL_TARGET
   apm install nuclide || true
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
   target_done $INSTALL_TARGET
fi

if is_install "pycharm"; then
   echo_install $INSTALL_TARGET
   sudo snap install pycharm-community --classic
   target_done $INSTALL_TARGET
fi

if is_install "androidstudio"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/android-studio.zip https://dl.google.com/dl/android/studio/ide-zips/3.2.1.0/android-studio-ide-181.5056338-linux.zip
   sudo unzip /tmp/android-studio.zip -d /opt/android-studio
   sudo chmod +x /opt/android-studio/studio.sh
   sudo ln -s /opt/android-studio/studio.sh /usr/bin/android-studio
   sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
   target_done $INSTALL_TARGET
fi

if is_install "androidtools"; then
   echo_install $INSTALL_TARGET
   wget -N -O /tmp/android-sdktools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
   sudo unzip /tmp/android-sdktools.zip -d /opt/android-sdk
   sudo ln -s /opt/android-sdk/tools/bin/sdkmanager /usr/bin/sdkmanager
   sudo ln -s /opt/android-sdk/tools/bin/avdmanager /usr/bin/avdmanager
   target_done $INSTALL_TARGET
fi
