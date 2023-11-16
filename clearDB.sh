#!/bin/bash

#script to clear out contents of database upon ending use of detector.sh program
/bin/sqlite3 "" <<EndOfSqlite3Commands
ATTACH testDB AS db1;
DELETE FROM db1.tbl1;
DELETE FROM db1.tbl2;
VACUUM;
EndOfSqlite3Commands
