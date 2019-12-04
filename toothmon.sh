#!/bin/bash
# ---- t o o t h m o n ----
# displays an apple notification if any connected bluetooth device has low battery
if [ -z "$1" ]; then
    echo "Usage: toothmon.sh [low battery % limit], example: ./toothmon.sh 20"
    exit 1
fi
limit="$1"
battery=`/usr/sbin/ioreg -l \
    | grep "BatteryPercent\|Bluetooth Product Name" \
    | grep -B1 "\"BatteryPercent\"" \
    | sed "s/.*= //g" \
    | sed "s/\"//" \
    | sed "s/\"/:/"`
percentages=`echo "$battery" | egrep -x '[0-9]+'`
if [ -z "$percentages" ]; then
    exit 0
fi
while IFS= read -r percent
do
    if [ "$percent" -lt "$limit" ]; then
        battery=`echo "$battery" | tr "\n" " " | sed 's/ --/% -/g' | sed 's/ $/%/g'`
        /usr/bin/osascript -e "display notification \"$battery\" with title \"Bluetooth Device LOW BATTERY!\""
        exit 0
    fi
done <<< "$percentages"
