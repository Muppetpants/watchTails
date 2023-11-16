#!/bin/bash

#find detector.sh script process ids and assign to variable
scriptProcess=$(ps -aux | grep -w "detector" | grep -v grep | awk '{print $2}')

#issue temporary stop command to detector.sh program
sudo kill -TSTP $scriptProcesses

