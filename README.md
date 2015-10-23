# backup-keeper
Scans for items in YYYY-MM-DD-NAME.EXT format and organises them
with monthly and weekly archiviation.

At [3DGIS](http://www.3dgis.it) we use this to organise our tarball backups into a useful structure.
Every backup snapshot, in the DATE-NAME.EXT format, is put into a directory which gets easily clobbered with time and growing data.

**With this script you can retain backups with a time based logic**, keeping N monthly snapshots, M weekly snapshots and D daily snapshot per filename (the NAME part of the file).

It works on everything you want in the form of **YYYY-MM-DD-NAME.EXT**.
	
# Usage
    Usage: ./backup-keeper.sh [-h] [-m MONTHLY_ARCHIVE_DIR] [-w WEEKLY_ARCHIVE_DIR]
		[-k MONTHLY_RETAIN] [-l WEEKLY_RETAIN] [-d DAILY_RETAIN]
		[-p BACKUP_PATH]

    -h          display this help and exit
    -m		monthly archive directory name. it will be created if missing
    -w		weekly archive directory name. it will be created if missing
    -k		number of monthly items to retain
    -l		number of weekly items to retain
    -d		number of weekly items to retain
    -p		path containing items to keep

		Retained item number follows this rule:
		-1 	disable archiving
		0 	keeps everything
		N 	keeps the last N

