#!/bin/bash

HOME_WP="${HOME}/Consultant/wordpress"
DB_WP="blogjpmena"
LOCAL_MYSQL_DUMP="${DB_WP}.sql"
REMOTE_MYSQL_DUMP="${DB_WP}_and.sql"
TMP_MYSQL_DUMP="tmp_${REMOTE_MYSQL_DUMP}"
COLLATE_LOCAL="utf8mb4_unicode_520_ci"
COLLATE_AND="utf8mb4_general_ci"
URL_LOCAL="blogjpmena.and"
URL_AND="blog.jpmena.eu"

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}

LOG_DIR=$(pwd)
LOGFILE=$LOG_DIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log

function export_local_database(){
	database=$1
	dump_file=$2
	trace "DOING $(basename $0) / ${FUNCNAME[0]}"
	mysqldump -u${database} -p${database} ${database} > ${dump_file}
}

# changing encodings acccording to
## https://stackoverflow.com/questions/30720078/utf8mb4-issue-uploading-to-1and1-com
## see README.md
##
function convert_encodings(){
   trace "DOING $(basename $0) / ${FUNCNAME[0]}"
	sed -re "s/${COLLATE_LOCAL}/${COLLATE_AND}/g" $1 > $2
}

function change_url_home(){
   trace "DOING $(basename $0) / ${FUNCNAME[0]}"
	sed -re "s/${URL_LOCAL}/${URL_AND}/g" $1 > $2
}


backup_wp_for_and(){
	trace "DOING $(basename $0) / ${FUNCNAME[0]}"
	home=$1
	home_dir=$(dirname $home)
	archive_name=$(basename $home)
	old_pwd=$(pwd)
	cd $home
	rm -f "*.sql"
	export_local_database "${DB_WP}" "${LOCAL_MYSQL_DUMP}"
	convert_encodings "${LOCAL_MYSQL_DUMP}" "${TMP_MYSQL_DUMP}"
	change_url_home "${TMP_MYSQL_DUMP}" "${REMOTE_MYSQL_DUMP}"
	trace "nettoyage"
	gz_dump="${REMOTE_MYSQL_DUMP}.gz"
	if [ -f "${gz_dump}" ]; then
		rm "${gz_dump}"
	fi
	gzip "${REMOTE_MYSQL_DUMP}"
	trace "${gz_dump} créé ..."
	trace "autres nettoyages ..."
	rm "${TMP_MYSQL_DUMP}"
	rm "${LOCAL_MYSQL_DUMP}"
	cd $home_dir
	trace "production de l'archive ${archive_name}.tgz"
	tar czf "${archive_name}.tgz" -C $home_dir $archive_name
	cd $old_pwd
}

backup_wp_for_and $HOME_WP | tee $LOGFILE
