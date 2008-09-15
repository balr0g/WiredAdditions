#!/bin/sh

rm -f WiredAdditions/English.lproj/Localizable.strings
find . -name "*.[mc]" | xargs genstrings -s WILS -q -o WiredAdditions/English.lproj -a

rm -f WiredNetworking/English.lproj/Localizable.strings
find . -name "*.[mc]" | xargs genstrings -s WNLS -q -o WiredNetworking/English.lproj -a

exit 0
