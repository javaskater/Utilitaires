#!/usr/bin/env bash

if [ "$#" -eq 1 ]
then
    export MUSER="$1"
	export MPASS="$1"
	export MDB="$1"
elif [ "$#" -eq 3 ]
then
	export MUSER="$1"
	export MPASS="$2"
	export MDB="$3"
else
	echo "Illegal number of parameters found $# parameters, should be 1 or 3"
	echo "Usage: $0 {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name}"
	echo "Drops all tables from a MySQL"
	exit 1
fi

# Detect paths
MYSQL=$(which mysql)
AWK=$(which awk)
GREP=$(which grep)
 
TABLES=$($MYSQL -u $MUSER -p$MPASS $MDB -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )
 
for t in $TABLES
do
	echo "Deleting $t table from $MDB database..."
	$MYSQL -u $MUSER -p$MPASS $MDB -e "drop table $t"
done
