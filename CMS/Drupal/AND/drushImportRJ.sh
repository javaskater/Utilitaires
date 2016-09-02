#!/bin/bash

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}



#the php client I use on 1AND1
PHP_CLI=php5.5

#Where I downloaded the phar file
DRUSH_BINARY=$HOME/drush.phar

#I have to tell drush which Drupal' site he works on
DRUPAL_SITE_HOME=$HOME/sites_jpm/d8rif

#The directory where the import's csv files are located ....
IMPORT_DIR=$(dirname $DRUPAL_SITE_HOME)/importations

LOG_DIR=$(dirname $DRUPAL_SITE_HOME)
LOGFILE=$LOGDIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log



main(){
	trace "I import Randonnees de Jour from $IMPORT_DIR/randonnees.csv"
	#for the import's usage see: https://github.com/javaskater/rif_imports
	$PHP_CLI $DRUSH_BINARY -r $DRUPAL_SITE_HOME rirj --csv=$IMPORT_DIR/randonnees.csv
	if [ $? -eq 0 ]; then
		trace " - Randonnees de Jour's Import : OK"
	else
		trace " - Randonnees de Jour's Import : KO (see ${LOGFILE})"
		exit 1
	fi
	trace "I erase the Randonnees de Jour to be found in $IMPORT_DIR/randonnees.eff.csv"
	#for the erase's usage see: https://github.com/javaskater/rif_import
	$PHP_CLI $DRUSH_BINARY -r $DRUPAL_SITE_HOME rerj --csv=$IMPORT_DIR/randonnees.eff.csv
	if [ $? -eq 0 ]; then
		trace " - Randonnees de Jour's Erasing : OK"
	else
		trace " - Randonnees de Jour's Erasing : KO (see ${LOGFILE})"
		exit 1
	fi
}

main | tee $LOGFILE

