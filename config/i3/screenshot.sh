#!/bin/sh

# screenshot with Lightshot (over wine)
cd "/home/andrey/.wine/drive_c/Program Files (x86)/Skillbrains/lightshot/"
./Lightshot.exe
cd "/home/andrey/.wine/drive_c/Program Files/Skillbrains/lightshot/"
./Lightshot.exe
notify-send Lightshot "Lightshot open in system menu\nUse 'Take a screenshot'"

# sreenshot with gimp editor
#scrot -e 'mv $f /tmp/ && gimp /tmp/$f'
