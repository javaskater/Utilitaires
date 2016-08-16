#!/usr/bin/env bash

if [ "$#" -eq 7 ]
then
    export SITENAME="$1"
    export ADMINUSER="$2"
    export ADMINPASSWD="$3"
    export ADMINMAIL="$4"
    export PHPPROJECT="$5"
    export LOCALE="$6"
    export MUSER="$7"
	export MPASS="$7"
	export MDB="$7"
	export HOST="localhost"
elif [ "$#" -eq 10 ]
then
	export SITENAME="$1"
    export ADMINUSER="$2"
    export ADMINPASSWD="$3"
    export ADMINMAIL="$4"
	export PHPPROJECT="$5"
    export LOCALE="$6"
	export MUSER="$7"
	export MPASS="$8"
	export MDB="$9"
	export HOST="$10"
else
	echo "Illegal number of parameters found $# parameters, should be 7 or 10"
	echo "Usage: $0 {Site Name} {Admin USer} {Admin Password} {Admin Email} {PHP absolute path} {Locale} {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name} {MySQL-Host-Name}"
	echo " + The first parameter will always be the title that appear on the front page ..."
	echo " + The second parameter will always be the username of the super-admin user (user 0) ..."
	echo " + The third parameter will always be the password of the super-admin user (user 0) ..."
	echo " + The fourth parameter will always be the email address for Drupal8 to communicate with the super-admin user (user 0) ..."
	echo " + The fifth parameter will always be the php project absolute path ..."
	echo " + The sixth parameter will be the locale (other than english) you want Drupal be running with, locale parameter should be:"
	echo " ++ fr for french"
	echo " ++ de for german"
	echo " + if only 7 parameter then:"
	echo " ++ MySQL-User-Name MySQL-User-Password MySQL-Database-Name are taken form the last parameter and MySQL-Host-Name is localhost !!!"
	echo " + if 10 parameters then:"
	echo " ++ MySQL-User-Name MySQL-User-Password MySQL-Database-Name and MySQL-Host-Name will be completed with the 4 last parameters (in that order) !!!"
	echo "Install a brand new Drupal8 with a specific local... "
	exit 1
fi

# Detect paths
#AWK=$(which awk)
#GREP=$(which grep)
DRUSH=$(which drush)
LOCALUSER=$(whoami)
APACHEGROUP="www-data"

LOGDIR=$(pwd)
LOGFILE=$LOGDIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}


main(){
	trace " + first download the latest Drupal 8 version and rename it to ${PHPPROJECT}"
	$DRUSH dl drupal --drupal-project-rename=$(basename ${PHPPROJECT}) --destination=$(dirname ${PHPPROJECT}) -y 2>&1
	if [ $? -eq 0 ]; then
		trace " - Download the latest Drupal8 version : OK"
	else
		trace " - Download the latest Drupal8 version : KO (see ${LOGFILE})"
		exit 1
	fi
	
	trace " + then install the ${SITENAME} with locale ${LOCALE}"
	$DRUSH site-install standard --db-url="mysql://${MUSER}:${MPASS}@${HOST}/${MDB}" --site-name="${SITENAME}"  --account-name="${ADMINUSER}" --account-pass="${ADMINPASSWD}" –account-mail="${ADMINMAIL}" -r "${PHPPROJECT}" --locale="${LOCALE}" -y 2>&1
	if [ $? -eq 0 ]; then
		trace " - Installation of ${SITENAME} : OK"
	else
		trace " - Installation of ${SITENAME} : KO (see ${LOGFILE})"
		exit 1
	fi
	DEFAULT_DIR=${PHPPROJECT}/sites/default
	trace " + changing rights at ${DEFAULT_DIR} for the cache"
	chown -R ${LOCALUSER}:${APACHEGROUP} ${DEFAULT_DIR} 2>&1
	if [ $? -eq 0 ]; then
		trace " - changing rights at ${DEFAULT_DIR} : OK"
	else
		trace " - changing rights at ${DEFAULT_DIR} : KO (see ${LOGFILE})"
		exit 1
	fi
	trace " End of the installation ..."
	trace " Making a Backup of the freshly installed Drupal 8 WebSite ..."
	BACKUPFILE="${PHPPROJECT}_${LOCALE}_$(date +%Y%m%d_%H%M%S).tar"
	$DRUSH --root=${PHPPROJECT} ard --destination=${BACKUPFILE} 2>&1
	if [ $? -eq 0 ]; then
		trace " - result of Backup : OK (the path for the BackupFile is ${BACKUPFILE}"
	else
		trace " - result of Backup : KO (see ${LOGFILE})"
		exit 1
	fi
	
}


main | tee -a $LOGFILE
