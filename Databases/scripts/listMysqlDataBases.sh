#!/usr/bin/env bash

if [ "$#" -eq 1 ]
then
    export MUSER="$1"
	export MPASS="$1"
	export MDB=""
	export HOST="localhost"
elif [ "$#" -eq 4 ]
then
	export MUSER="$1"
	export MPASS="$2"
	export MDB="$3"
	export HOST="$4"
else
	echo "Illegal number of parameters found $# parameters, should be 1 or 4"
	echo "Usage: $0 {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name} {MySQL-Host-Name}"
	echo " + if only 1 parameter then:"
	echo " ++ MySQL-User-Name MySQL-User-Password MySQL-Database-Name are the same and MySQL-Host-Name is localhost !!!"
	echo " + if 4 parameters then:"
	echo " ++ MySQL-User-Name MySQL-User-Password MySQL-Database-Name and MySQL-Host-Name will be completed with the 4 parameters (in that order) !!!"
	echo "Drops all tables from a MySQL"
	exit 1
fi

# Detect paths
MYSQL=$(which mysql)
AWK=$(which awk)
GREP=$(which grep)
 
DATABASES=$($MYSQL -u$MUSER -p$MPASS -h$HOST $MDB -e 'show databases' | $AWK '{ print $1}' | $GREP -v '^Database' )
 
for d in $DATABASES
do
	echo "$d"
	#$MYSQL -u$MUSER -p$MPASS $MDB -h$HOST -e "drop database $d"
done
