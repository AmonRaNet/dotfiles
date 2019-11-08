#! /bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "DevKit: compilers, SDK, IDE"
    exit
fi

source $DIR/config.sh

qtcreator_version=4.8
qtcreator_build=1
qtcreator_spellcheck_version=2.0.1
if is_ubuntu18; then
    libhunspell_version=1.6
else
    libhunspell_version=1.3
fi

set +e
choice=($(whiptail \
  --checklist "C++ tools setup (AmonRaNet)" 20 80 14 \
  cmake "cmake (latest release)" off \
  ninja "ninja" off \
  bazel "bazel" off \
  clang-6.0 "clang compiler 6.0" off \
  clang-format-6.0 "clang-format 6.0" off \
  clang-tidy-6.0 "clang-tidy 6.0" off \
  ccache "ccache" off \
  qtframework "Qt framework" off \
  qtcreator "QtCreator v$qtcreator_version.$qtcreator_build" off \
  qtspellcheck "Qt spellCheck plugin v$qtcreator_spellcheck_version" off \
  vcode "Visual Studio Code on Linux" off \
  pycharm "PyCharm" off \
  androidstudio "Android Studio" off \
  androidtools "Android commmand line tools" off \
  3>&1 1>&2 2>&3))
no_choice_exit
set -e

if is_install "ninja"; then
    echo_install "ninja"
    sudo apt-get --assume-yes --no-install-recommends install ninja-build
fi

if is_install "clang-6.0"; then
    echo_install "clang-6.0"
    sudo apt-get --assume-yes --no-install-recommends install clang-6.0
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-6.0 1000
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-6.0 1000
    sudo update-alternatives --config clang
    sudo update-alternatives --config clang++
fi

if is_install "clang-format-6.0"; then
    echo_install "clang-format-6.0"
    sudo apt-get --assume-yes --no-install-recommends install clang-format-6.0
    sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-6.0 1000
    sudo update-alternatives --config clang-format
fi

if is_install "clang-tidy-6.0"; then
    echo_install "clang-tidy-6.0"
    sudo apt-get --assume-yes --no-install-recommends install clang-tidy-6.0
    sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-6.0 1000
    sudo update-alternatives --config clang-tidy
fi

if is_install "ccache"; then
    echo_install "ccache"
    sudo apt-get --assume-yes --no-install-recommends install ccache
    sudo /usr/sbin/update-ccache-symlinks
    ccache --max-size=50G
    source-auto script bash ccache "export PATH=\"/usr/lib/ccache:\$PATH\""
    source-auto script fish ccache "set PATH /usr/lib/ccache \$PATH"
    source-auto script zsh  ccache "export PATH=\"/usr/lib/ccache:\$PATH\""
fi

if is_install "cmake"; then
   echo_install "cmake"
   build_in_docker $DIR/make_cmake.sh
fi

if is_install "bazel"; then
   echo_install "bazel"
   wget -q https://bazel.build/bazel-release.pub.gpg -O- | sudo apt-key add -
   sudo add-apt-repository -y "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8"
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install bazel
fi

if is_install "qtframework"; then
   echo_install "qtframework"
   wget -N -O /tmp/qt-x64-online.run http://ftp.fau.de/qtproject/official_releases/online_installers/qt-unified-linux-x64-online.run
   sudo chmod +x /tmp/qt-x64-online.run
   /tmp/qt-x64-online.run
fi

if is_install "qtcreator"; then
   echo_install "qtcreator"
   wget -N -O /tmp/qt-x64-creator.run http://ftp.fau.de/qtproject/official_releases/qtcreator/$qtcreator_version/$qtcreator_version.$qtcreator_build/qt-creator-opensource-linux-x86_64-$qtcreator_version.$qtcreator_build.run
   sudo chmod +x /tmp/qt-x64-creator.run
   sudo /tmp/qt-x64-creator.run
fi

if is_install "qtspellcheck"; then
   echo_install "qtspellcheck"
   sudo apt-get --assume-yes --no-install-recommends install libhunspell-${libhunspell_version}-0
   qtcreator_dir=$(input_dialog "QtCreator directory" "/opt/qtcreator-$qtcreator_version.$qtcreator_build")
   wget -N -O /tmp/qt-x64-spellcheck.tar.gz https://github.com/CJCombrink/SpellChecker-Plugin/releases/download/v$qtcreator_spellcheck_version/SpellChecker-Plugin_v${qtcreator_spellcheck_version}_Hunspell_v${libhunspell_version}_x64.tar.gz
   sudo tar -xzvf /tmp/qt-x64-spellcheck.tar.gz --directory $qtcreator_dir --strip-components 1
   if yesno_dialog "Use default dictionary package?"; then
       sudo apt-get --assume-yes --no-install-recommends install hunspell-en-gb
       msg_dialog "Select and apply dictionary (from /usr/share/hunspell) in QtCreator (Menu->Tools->Options->Spell Checker)."
   else
       nohup xdg-open https://sourceforge.net/projects/wordlist/files/speller/2018.04.16/hunspell-en_US-2018.04.16.zip >/dev/null 2>&1
       msg_dialog "Please download dictionary, unpack and apply it in QtCreator (Menu->Tools->Options->Spell Checker)"
   fi
fi

if is_install "vcode"; then
   echo_install "vcode"
   wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
   sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
   sudo apt-get -q update
   sudo apt-get --assume-yes --no-install-recommends install code
fi

if is_install "pycharm"; then
   echo_install "pycharm"
   sudo snap install pycharm-community --classic
fi

if is_install "androidstudio"; then
   echo_install "androidstudio"
   wget -N -O /tmp/android-studio.zip https://dl.google.com/dl/android/studio/ide-zips/3.2.1.0/android-studio-ide-181.5056338-linux.zip
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
