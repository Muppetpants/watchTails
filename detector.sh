#!/bin/bash

while [true]
do
# Start kismet in daemon mode
kismet --daemonize
# Run for x seconds (get user input)
sleep 30

# Obtain and end capture process
kismetProcesses=$(ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}')
sudo kill -15 $kismetProcesses
sleep 10

# Force Kill capture process if previous step failed
if ps -aux | grep -w "kismet" | grep -v grep | awk '{print $2}'
then
	sudo kill -9 $kismetProcesses
	echo "SIGKILL Required to terminate process"
fi

# Database work
mv Kismet*.kismet db1
date=$(date +%Y%m%d%H%M%S)

# sqlite commands to configure databases and process data
sqlite3 "" <<EndOfSqlite3Commands
ATTACH db1 AS db1;
ATTACH testDB AS db2;
# sqlite commands to fill second databse with the MACs and approximate time of detection (date)
INSERT INTO db2.tbl1(macs) SELECT (devmac) FROM db1.devices;
UPDATE db2.tbl1 SET date = $date WHERE date IS NULL;

#IGNORE LIST

#delete MACs of user devices from database to avoid false positives (ignore list)
DELETE FROM db2.tbl1 WHERE macs = "DC:A6:32:C1:B8:CD";
#use sql to count the number of times kismet has detected device MACs and insert into table
REPLACE INTO db2.tbl2(macs,counter) SELECT macs, COUNT(macs) FROM db2.tbl1 GROUP BY macs HAVING COUNT(macs) > 2
EndOfSqlite3Commands

# Remove journal file created by forcefully killing kismet
rm Kismet* ###### should this be a *.journal file instead?
sleep 5

#select for devices following us (detected 3 or more times) and assign to variable
following=$( sqlite3 "testDB" "select macs from tbl2" )

#see if there are any devices following us and alert if true
if [ ! -z "${following}" ]
then
	zenity --info --text='You may have a tail!'
fi

#wait for 10 seconds before running script again
sleep 10   ### take a look at this 

#end of while loop
done






#if kismet is still running (usually the case) then forcefully kill it


#rename kismet database file to db1

