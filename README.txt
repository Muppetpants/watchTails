Run this on a Linux System (Kali is preferrable)
Install Kismet if not installed already
	Command: sudo apt install kismet

Download all these files (detector.sh, clearDB.sh, test.DB) to a single folder in your user's home directory

Make a cronjob that runs detector.sh however often as you'd like (leave at least 2 minutes between runs)
	Command: sudo crontab -e
	Write: */5 * * * * bash /home/<username>/<directory>/detector.sh

When you are done using this program, run clearDB.sh to clear the contents of the database
	Command: ./clearDB.sh

When you are done using this program, turn off the device (unplug from power source)

To add your devices to the ignore list:
	Edit the detector.sh file
	Command: nano detector.sh
	Look in the SQLite command area and copy the line that starts with DELETE (Look for IGNORE LIST comment)
	Make a new line and paste the copied line there
	Change the Mac address in quotation marks to match the MAC or BD_ADDR of your devices

To know what the MAC and BD_ADDR are for your devices:
	Go to an isolated area (far from buildings and other signals)
	Turn on all connections (Wifi, BT, on your phone, vehicle, and other devices)
	Run this program
	Command: sudo ./detector.sh
	Look at the testDB file to see the MAC addresses in table 1 (tbl1)
	Command: open testDB
