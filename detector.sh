#!/bin/bash

#while loop to run script continuously
while true
do

#start kismet in daemon mode
kismet --daemonize

#run for 30 seconds
sleep 30

#identify primary kismet process
kismetProcesses=$(ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}')

#attempt to gracefully kill kismet (will force kismet to output to database file)
sudo kill -15 $kismetProcesses

#wait for kismet to kill process
sleep 10

#if kismet is still running (usually the case) then forcefully kill it
if ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}'
then
	sudo kill -9 $kismetProcesses
	echo "had to sigkill"
fi

#rename kismet database file to db1
mv Kismet*.kismet db1

#set date variable
date=$(date +%Y%m%d%H%M%S)

#sqlite commands to configure databases and process data
sqlite3 "" <<EndOfSqlite3Commands
ATTACH db1 AS db1;
ATTACH testDB AS db2;
#sql commands to fill second databse with the MACs and approximate time of detection (date)
INSERT INTO db2.tbl1(macs) SELECT (devmac) FROM db1.devices;
UPDATE db2.tbl1 SET date = $date WHERE date IS NULL;

#IGNORE LIST

#delete MACs of user devices from database to avoid false positives (ignore list)
DELETE FROM db2.tbl1 WHERE macs = "DC:A6:32:C1:B8:CD";
#use sql to count the number of times kismet has detected device MACs and insert into table
REPLACE INTO db2.tbl2(macs,counter) SELECT macs, COUNT(macs) FROM db2.tbl1 GROUP BY macs HAVING COUNT(macs) > 2
EndOfSqlite3Commands

#remove journal file created by forcefully killing kismet
rm Kismet*

#wait for database to update
sleep 5

#select for devices following us (detected 3 or more times) and assign to variable
following=$( sqlite3 "testDB" "select macs from tbl2" )

#see if there are any devices following us and alert if true
if [ ! -z "${following}" ]
then
	zenity --info --text='You may have a tail!'
fi

#wait for 10 seconds before running script again
sleep 10

#end of while loop
done
