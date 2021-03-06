#!/bin/bash
# 
# 2016-10-12 - Initial
# 2018-01-01 - add Scale option
# 2019-04-16 - add docker
#
# run container: docker exec -ti docker_host_db_1  bash
# add execute permissions: chmod +x /home/ubuntu/backup/_pgdump_host_backup_docker.bash
# run backup:    /home/ubuntu/backup/_pgdump_host_backup_docker.bash


clear

echo "ECHO ------------------------------------------------------------"
echo "ECHO Easy Backup Postgresql database (host, custom format, Scale)"
echo "ECHO Livesey Inc., 2016-2019"
echo "ECHO ------------------------------------------------------------"

CURDATETIMET=`date '+%Y%m%dT%H%M%S'`

print_msg() {
    echo "`date '+%Y/%m/%d %H:%M:%S'` $1"
}

read -p "Is it docker? (1-yes, 2-no) [1]: " ISDOCKER
if [ "$ISDOCKER" == "2" ]; then
	HOST=54.93.205.16
	PATH4BACKUP="/home/ubuntu/.backup/from_host/"
else
	HOST=52.59.34.33
	PATH4BACKUP="/home/ubuntu/backup/from_host/"
fi

read -p "format (1-custom, 2-sql) [2]: " FORMAT_DUMP 
if [ "$FORMAT_DUMP" == "1" ]; then
     FORMAT_DUMP='--blobs --format=custom'
	 FILE_EXT='custom'
else
     FORMAT_DUMP=""
	 FILE_EXT='sql'
fi

read -p "Scale (1-full, 2-schema-only) [1]: " SCALE
if [ "$SCALE" == "2" ]; then
     SCALE='--schema-only'
else
     SCALE=""
fi

print_msg "COMMENT_02: HOST=$HOST"
print_msg "COMMENT_03: PATH4BACKUP=$PATH4BACKUP"
print_msg "COMMENT_04: FORMAT_DUMP=$FORMAT_DUMP"
print_msg "COMMENT_05: FILE_EXT=$FILE_EXT"
print_msg "COMMENT_06: SCALE=$SCALE"


read -p "password for username=user8: " PGPASSWORD_INPUT 


#for db_name in plabor
for db_name in plabor drupal8
do
	print_msg "COMMENT_10: db_name=$db_name"

	FILE4BACKUP="pg_dump_$db_name.$FILE_EXT"
	PATHFILE4BACKUP="$PATH4BACKUP$FILE4BACKUP"
	PATHFILE4ARCHIVE="$PATH4BACKUP$FILE4BACKUP"_ubuntu_"$CURDATETIMET$SCALE.tar.bz2"
	print_msg "COMMENT_20: FILE4BACKUP=$FILE4BACKUP"
	print_msg "COMMENT_30: PATHFILE4BACKUP=$PATHFILE4BACKUP"
	print_msg "COMMENT_40: PATHFILE4ARCHIVE=$PATHFILE4ARCHIVE"
	
	PGPASSWORD=$PGPASSWORD_INPUT pg_dump $db_name --host="$HOST" --port=5432 --username=user8 --clean $SCALE $FORMAT_DUMP > $PATHFILE4BACKUP
	print_msg "COMMENT_50: Backup to file: $PATHFILE4BACKUP"
	
	tar -cvjpf $PATHFILE4ARCHIVE -C $PATH4BACKUP $FILE4BACKUP
	rm "$PATHFILE4BACKUP"
	print_msg "COMMENT_60: Archived to file: $PATHFILE4ARCHIVE"

done