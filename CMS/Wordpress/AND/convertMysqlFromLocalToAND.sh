#!/bin/bash

DIR_DUMPS="${HOME}/CONSULTANT/wordpress"
LOCAL_MYSQL_DUMP="blogjpmena.sql"
REMOTE_MYSQL_DUMP="blogand.sql"
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

#I have to tell drush which Drupal' site he works on
DRUPAL_SITE_HOME=$HOME/sites_jpm/d8rif

#The directory where the import's csv files are located ....
IMPORT_DIR=$(dirname $DRUPAL_SITE_HOME)/importations

LOG_DIR=$(pwd)
LOGFILE=$LOGDIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log

# changing encodings acccording to
## https://stackoverflow.com/questions/30720078/utf8mb4-issue-uploading-to-1and1-com
## see README.md
##
function convert_encodings(){
   trace "DOING $0 / ${FUNCNAME[0]}"
	sed -re 's/utf8mb4_unicode_520_ci/utf8mb4_general_ci/g' $1 > $2
}

function change_url_home(){
   trace "DOING $0 / ${FUNCNAME[0]}"
	sed -re 's/blogjpmena.and/blog.jpmena.eu/g' $1 > $2
}


main(){
	old_pwd=$(pwd)
	cd $DIR_DUMPS
	
	convert_encodings "${LOCAL_MYSQL_DUMP}" "${TMP_MYSQL_DUMP}"
	change_url_home "${TMP_MYSQL_DUMP}" "${REMOTE_MYSQL_DUMP}"
	rm -f "${REMOTE_MYSQL_DUMP}.gz"
	gzip "${REMOTE_MYSQL_DUMP}"
	rm -f "${TMP_MYSQL_DUMP}"
	cd $old_pwd
}

main | tee $LOGFILE
