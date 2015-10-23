# backup-keeper
Scans for items in YYYY-MM-DD-NAME.EXT format and organises them
with monthly and weekly archiviation.

At [3DGIS](http://www.3dgis.it) we use this to organise our tarball backups into a useful structure.
Every backup snapshot, in the DATE-NAME.EXT format, is put into a directory which gets easily clobbered with time and growing data.

**With this script you can retain backups with a time based logic**, keeping N monthly snapshots, M weekly snapshots and D daily snapshot per filename (the NAME part of the file).

It works on everything you want in the form of **YYYY-MM-DD-NAME.EXT**.
	
# Usage
	./backup-keeper.sh [-h] [-m MONTHLY_ARCHIVE_DIR] [-w WEEKLY_ARCHIVE_DIR]
		[-k MONTHLY_RETAIN] [-l WEEKLY_RETAIN] [-d DAILY_RETAIN]
		[-p BACKUP_PATH]

	Options:
	-h	display this help and exit
	-m	monthly archive directory name. it will be created if missing
	-w	weekly archive directory name. it will be created if missing
	-k	number of monthly items to retain 
	-l	number of weekly items to retain
	-d	number of weekly items to retain
	-p	path containing items to keep 
		
	Retained item number follows this rule:
	-1 	disable archiving
	0 	keeps everything
	N 	keeps the last N

#Data structure example
We want to keep 12 months, 4 weeks and 7 days.

    ./backup-keeper.sh -k 12 -l 4 -d 7 -p directory

##Before running backup-keeper

    directory
		|-- 2015-10-23-file.tar.gz
		|-- 2015-10-22-file.tar.gz
		|-- ...
		|-- 2015-10-17-file.tar.gz
		|-- ...
		|-- 2015-09-30-file.tar.gz
		|-- ...

##After running backup-keep

    directory
	    |-- monthly
			|-- 2015-10-01-file.tar.gz
			|-- 2015-09-01-file.tar.gz
			|-- ...
	    |-- weekly
			|-- 2015-10-19-file.tar.gz
			|-- 2015-10-12-file.tar.gz	
			|-- ...				
		|-- 2015-10-23-file.tar.gz
		|-- 2015-10-22-file.tar.gz
		|-- ...
		|-- 2015-10-16-file.tar.gz
