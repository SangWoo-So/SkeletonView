#!/bin/zsh
# Prints the simulator to use, booting it if needed: $DEVICE if set, else the first booted one, else the first available iPhone.
D=$DEVICE
[[ -z $D ]] && D=$(xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1)
[[ -z $D ]] && D=$(xcrun simctl list devices available | grep iPhone | grep -oE '[0-9A-F-]{36}' | head -1)
xcrun simctl boot $D >/dev/null 2>&1; xcrun simctl bootstatus $D >/dev/null 2>&1
echo $D
