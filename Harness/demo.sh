#!/bin/zsh
# Starts the looping visual demo (show → apply while skeleton → hide).
H=$(dirname $0:A); D=$($H/device.sh)
xcrun simctl install $D $H/build/Harness.app
SIMCTL_CHILD_SCENARIO=demo xcrun simctl launch --terminate-running-process $D com.skeletonview.harness
