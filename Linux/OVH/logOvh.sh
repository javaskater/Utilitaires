#!/bin/bash
#copy of http://www.memoinfo.fr/tutoriels-web/recuperer-logs-mutualise-ovh/


# Usage :	./script-name.sh domaine mm-aaaa
# ex : 		./script-name.sh rifrando.asso.fr 08-2016 logusername loguserpassword error

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}

usage(){
	echo "Le nombre de parramètres doit être 4 ou 5"
	echo "Usage: $0 {URL Site} {Mois récupéré} {Logs User Name} {Logs User Password} {type de logs}"
	echo " + URL Site est le nom de domaine du contrat OVH dont on veut réupérerut les logs"
	echo " + Logs User Name est le nom utilisateur demandé par l'authentification basique OVH de rrécupération de Logs"
	echo " + Logs User Password est le mot de passe associé à l'utilisateur précéddent demandé par l'authentification basique OVH de rrécupération de Logs"
	echo "+ type de logs est renseigné à "
	echo "Récupère les fichiers de Logs d'u type donné pour un domaine donné et un mois donné"
	echo "+ si le 5ème paramètre n'est pas renseigné ou est vide: ce sont les access logs APACHE qui sont récupérées"
	echo "+ si le 5ème paramètre est renseigné: ce sont les logs OVH qui sont récupérées pour le type en question lequel peut être:"
	echo "++ error: logs des erreurs apache"
	echo "++ ftp: logs des tranferts FTP vers/depuis l'hébergement"
	echo "++ ssh: logs des acccès ssh sur l'hébergement"
	echo "++ out : logs des acccès TCP sur l'hébergement - à précciser !!!!"
	echo "++ cron: logs des des tâches planifiées qui ont été déclenchées sur l'hébergement"
	exit 1
}

if [ "$#" -eq 4 ]
then
    # votre domaine, sera passé en paramètre de la commande
	SITE=$1
	# période, sera passée en paramètre de la commande
	PERIODE=$2
	# login de votre compte OVH
	LOGIN=$3
	# mot de pa votre compte OVH
	PASS=$4
	URL=https://logs.ovh.net/$SITE/logs-$PERIODE/
elif [ "$#" -eq 5 ]
then
	# votre domaine, sera passé en paramètre de la commande
	SITE=$1
	# période, sera passée en paramètre de la commande
	PERIODE=$2
	# login de votre compte OVH
	LOGIN=$3
	# mot de pa votre compte OVH
	PASS=$4
	# type de logs OVH autre que web/access (error, ftp, ssh, out, cron)
	TYPE=$5
	URL=https://logs.ovh.net/$SITE/logs-$PERIODE/$TYPE/
else
	usage
fi


if [ -z "$TYPE" ]
then
	TYPE=web
fi
# Répertoire de destination.
DOSSIER=$HOME/$SITE/$TYPE/$PERIODE
LOGDIR=$DOSSIER
LOGFILE=$LOGDIR/$(basename $0)_$(date +%Y%m%d_%H%M%S).log
trace "La sortie console ssera aussi dans : $LOGFILE"


main(){
	# Créé le dossier qui va récupérer les logs. Etape obligatoire sinon wget retourne une erreur concernant ses logs
	trace "Création du dossier $DOSSIER"
	mkdir -p $DOSSIER

	# Téléchargement des logs via wget avec les options suivantes :
	trace "Téléchargement des logs..."
	wget -nv -nd -r -A.gz -P$DOSSIER https://logs.ovh.net/$SITE/logs-$PERIODE/error/ --http-user=$LOGIN --http-password=$PASS

	trace "terminé vous pouvez récupérer les logs sous : ${DOSSIER}"
}

main | tee $LOGFILE
