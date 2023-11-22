#!/bin/bash

#find detector.sh script process ids and assign to variable
scriptProcess=$(ps -aux | grep -w "detector" | grep -v grep | awk '{print $2}')

#issue continue command to the temorarily stopped script processes
sudo kill -CONT $scrpitProcesses
