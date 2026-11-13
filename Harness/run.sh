#!/bin/zsh
# usage: run.sh [scenario]  — default "all": every check in one launch. Returns as soon as the run ends.
H=$(dirname $0:A); D=$($H/device.sh); S=${1:-all}
xcrun simctl install $D $H/build/Harness.app
START=$(date "+%Y-%m-%d %H:%M:%S")
SIMCTL_CHILD_SCENARIO=$S xcrun simctl launch --terminate-running-process $D com.skeletonview.harness >/dev/null
for i in $(seq 1 60); do
  sleep 1
  OUT=$(xcrun simctl spawn $D log show --start "$START" --style compact --predicate 'process == "Harness"' 2>&1 \
        | grep -E "RESULT\[|uncaught exception|Fatal error")
  if echo "$OUT" | grep -qE "uncaught exception|Fatal error"; then break; fi
  if [[ $S == all ]]; then echo "$OUT" | grep -q "ALL DONE" && break
  elif ! xcrun simctl spawn $D launchctl list 2>/dev/null | grep -q com.skeletonview.harness; then break; fi
done
echo "$OUT" | sed -E 's/^.*(RESULT|terminating|Fatal)/\1/' | cut -c1-220
