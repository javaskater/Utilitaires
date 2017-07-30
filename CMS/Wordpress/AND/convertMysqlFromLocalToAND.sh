#!/bin/bash

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}

#I have to tell drush which Drupal' site he works on
DRUPAL_SITE_HOME=$HOME/sites_jpm/d8rif

#The directory where the import's csv files are located ....
IMPORT_DIR=$(dirname $DRUPAL_SITE_HOME)/importations

LOG_DIR=$(dirname $DRUPAL_SITE_HOME)
LOGFILE=$LOGDIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log

# changing encodings acccording to
## https://stackoverflow.com/questions/30720078/utf8mb4-issue-uploading-to-1and1-com
function convert_encodings(){
   trace "TODO $0 / ${FUNCNAME[0]}"
}

function change_url_home(){
   trace "TODO $0 / ${FUNCNAME[0]}"
}


main(){
	trace "I import Randonnees de Jour from $IMPORT_DIR/randonnees.csv"


	if [ $? -eq 0 ]; then
		trace " - Randonnees de Jour's Erasing : OK"
	else
		trace " - Randonnees de Jour's Erasing : KO (see ${LOGFILE})"
		exit 1
	fi
}

main | tee $LOGFILE
