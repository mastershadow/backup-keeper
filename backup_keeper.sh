#!/bin/bash
##
## backup-keeper.sh
## ==
## Retain backups with a time based logic.
## 
## Developed by 3DGIS (http://www.3dgis.it)
## Licensed under the terms of the GNU Public License Version 2
##

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-m MONTHLY_ARCHIVE_DIR] [-w WEEKLY_ARCHIVE_DIR] 
		[-k MONTHLY_RETAIN] [-l WEEKLY_RETAIN] [-d DAILY_RETAIN] 
		[-p BACKUP_PATH]

Scans for items in YYYY-MM-DD_NAME.EXTENSION format and organizes them
with monthly and weekly archiviation.

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
EOF
}

backup_path="$(pwd)"
monthly_archive_dir="monthly"
weekly_archive_dir="weekly"
# -1 disable archiving. 0 keeps everything. N keeps the last N.
monthly_retain="12"
weekly_retain="4"
daily_retain="6"

monthly_archive_path=""
weekly_archive_path=""

OPTIND=1 
while getopts "hm:w:k:l:d:p:" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        m)  monthly_archive_dir=$OPTARG
            ;;
        w)  weekly_archive_dir=$OPTARG
            ;;
        k)  monthly_retain=$OPTARG
            ;;
        l)  weekly_retain=$OPTARG
            ;;
        d)  daily_retain=$OPTARG
            ;;
        p)  backup_path=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" 

# Sanity checks
if [ ! -d "$backup_path" ]; then
	echo "Backup path does not exist."
	exit 1
fi

if ! [ "$monthly_retain" -eq "$monthly_retain" ] 2> /dev/null; then
    echo "Monthly retain is not an integer."
    exit 1
fi

if ! [ "$weekly_retain" -eq "$weekly_retain" ] 2> /dev/null; then
    echo "Weekly retain is not an integer."
    exit 1
fi

if ! [ "$daily_retain" -eq "$daily_retain" ] 2> /dev/null; then
    echo "Daily retain is not an integer."
    exit 1
fi

if [ "$daily_retain" -lt 0 ] 2> /dev/null; then
    echo "Daily retain must be greater or equal to zero (or you will lose all of your files)."
    exit 1
fi

monthly_archive_path=$backup_path/$monthly_archive_dir;
if [ ! -d "$monthly_archive_path" ] && [ "$monthly_retain" -ge 0 ]; then
	echo "Monthly archive path $monthly_archive_path does not exist. Creating..." 1>&2
	mkdir -p $monthly_archive_path
	if [ $? -ne 0 ]; then
		echo "Cannot create" 1>&2
		exit 1
	fi
fi

weekly_archive_path=$backup_path/$weekly_archive_dir;
if [ ! -d "$weekly_archive_path" ] && [ "$weekly_retain" -ge 0 ]; then
	echo "Weekly archive path $weekly_archive_path does not exist. Creating..." 1>&2
	mkdir -p $weekly_archive_path
	if [ $? -ne 0 ]; then
		echo "Cannot create" 1>&2
		exit 1
	fi
fi
# End sanity checks

vardebug() {
echo "DEBUG"
echo $backup_path;
echo $monthly_archive_dir;
echo $weekly_archive_dir;
echo $monthly_retain;
echo $weekly_retain;
echo $daily_retain;
echo $monthly_archive_path;
echo $weekly_archive_path;
echo "END DEBUG"
}
#vardebug;

cleanarchive() {
			if [ "$monthly_retain" -ne -1 ]; then
				echo "==> Clearing monthly archive for $current_name"
				monthlyfiles=$(find $monthly_archive_path -type f -iname \*$current_name | sort -r)
				for af in $monthlyfiles; do
					current_monthly=$((current_monthly + 1))
					if [ "$monthly_retain" -ne 0 ] && [ "$current_monthly" -gt "$monthly_retain" ]; then
						echo "Deleting archived $af"
						rm $af
					else
						echo "Keeping archived $af"
					fi
				done
			fi
			if [ "$weekly_retain" -ne -1 ]; then
				echo "==> Clearing weekly archive for $current_name"
				weeklyfiles=$(find $weekly_archive_path -type f -iname \*$current_name | sort -r)
				for af in $weeklyfiles; do
					current_weekly=$((current_weekly + 1))
					if [ "$weekly_retain" -ne 0 ] && [ "$current_weekly" -gt "$weekly_retain" ]; then
						echo "Deleting archived $af"
						rm $af
					else
						echo "Keeping archived $af"
					fi
				done
			fi
}

declare -A items
current_name=
current_month=
current_week=
current_monthly=0
current_weekly=0
current_daily=0
fileslist="$(find $backup_path -maxdepth 1 -type f ! -iname .\* | sort -k4 -k1 -k2 -k3 -t- -r)"
for f in $fileslist; do
	filename=$(basename $f)
	date=${filename:0:10}
	name=${filename:11}
	month=${date:0:7}
	week=${date:0:5}$(date -d "$date" +%V)

	if [ ! "$current_name" == "$name" ]; then
		echo "==> Name changed from $current_name to $name"
		if [ -n "$current_name" ]; then
			cleanarchive;
		fi
		current_name=$name
		current_month=
		current_week=
		current_monthly=0
		current_weekly=0
		current_daily=0
		echo "==> Working on $name"
	fi

	if [ ! "$current_month" == "$month" ]; then
		current_month=$month
		echo "Current month $month"
		echo "Copying $filename to archive"
		cp $f $monthly_archive_path/$filename
	fi

	if [ ! "$current_week" == "$week" ]; then
		current_week=$week
		echo "Current week $week"
		echo "Copying $filename to archive"
		cp $f $weekly_archive_path/$filename
	fi

	current_daily=$((current_daily + 1))
	if [ "$daily_retain" -ne 0 ] && [ "$current_daily" -gt "$daily_retain" ]; then
		echo "Deleting $filename"
		rm $f
	else
		echo "Keeping $filename"
	fi
done
cleanarchive

