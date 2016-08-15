#!/usr/bin/env bash


if [ "$#" -eq 1 ]
then
    #l'accès à l'administration MYSQL en ligne de commande
	export MYSQLHOST='localhost'
	export MYSQLUSER='root'
	export MYSQLPASSWD='root'

	#la base que je veux créer
	export MYDB="$1"
	export MYDBUSER=${MYDB}
	export MYDBPASS=${MYDB}
elif [ "$#" -eq 6 ]
then
	#l'accès à l'administration MYSQL en ligne de commande
	export MYSQLHOST="$4"
	export MYSQLUSER="$5"
	export MYSQLPASSWD="$6"

	#la base que je veux créer
	export MYDB="$1"
	export MYDBUSER="$2"
	export MYDBPASS="$3"
else
	echo "Illegal number of parameters found $# parameters, should be 1 or 6"
	echo "Usage: $0 {MySQL-Database-Name} {MySQL-User-Name} {MySQL-User-Password} {MySQL-Host-Name} {MySQL-ROOTUser-Name} {MySQL-ROOTUser-Password}"
	echo " + if only 1 parameter then:"
	echo " ++ MySQL-Database-Name MySQL-User-Name MySQL-User-Password are the same, MySQL-Host-Name is localhost, {MySQL-ROOTUser-Name} and {MySQL-ROOTUser-Password} equal to root !!!"
	echo " + if 4 parameters then:"
	echo " ++ MySQL-User-Name MySQL-User-Password MySQL-Database-Name and MySQL-Host-Name will be completed with the 4 parameters (in that order) !!!"
	echo "Drops all tables from a MySQL"
	exit 1
fi



#la commande à passer

#cat <<EOF
mysql -u${MYSQLUSER} -p${MYSQLPASSWD} -h ${MYSQLHOST} <<EOF                                                     
CREATE DATABASE IF NOT EXISTS ${MYDB} CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON \`${MYDB}\`.* TO \`${MYDBUSER}\`@localhost IDENTIFIED BY '${MYDBPASS}';
EOF
resmysql=$?

echo "code retour de l'opération ${resmysql}"
