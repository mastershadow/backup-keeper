# backup-keeper
Scans for items in YYYY-MM-DD_NAME.EXTENSION format and organizes them
with monthly and weekly archiviation.

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
