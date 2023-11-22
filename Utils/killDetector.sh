#!/bin/bash

#find detector.sh script process ids and assign to variable
scriptProcess=$(ps -aux | grep -w "detector" | grep -v grep | awk '{print $2}')
#find kismet process ids and assign to variable
kismetProcess=$(ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}')

#kill detector.sh processes
sudo kill -9 $scriptProcess
#attempt to gracefully kill kismet process
sudo kill -15 $kismetProcess

#if there is still a kismet process, kill it
if ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}'
do
#kill kismet processes
sudo kill -9 $kismetProcess
fi

#if statement to see if a kismet file exists, then input data into database and clean up extra files
if test -f Kismet*.kismet
then

#rename kismet database file to db1
mv Kismet*.kismet dbTemp

#set date variable
date=$(date +%Y%m%d%H%M%S)

#sqlite commands to configure databases and process data
sqlite3 "" <<EndOfSqlite3Commands
ATTACH dbTemp AS db1;
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

#clean up database files left from interrupted kismet process
mv dbTemp db1
rm -f Kismet*

#end of if fiel extists statement
fi
