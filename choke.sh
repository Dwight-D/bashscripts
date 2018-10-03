#!/bin/bash
#Force kills clicked window

pid=$(xprop | cat | grep PID | cut -d " " -f 3)

kill -9 $pid
echo "I find your lack of response disturbing"
