#!/bin/bash
#copy of http://www.memoinfo.fr/tutoriels-web/recuperer-logs-mutualise-ovh/


# Usage :	./script-name.sh domaine mm-aaaa
# ex : 		./script-name.sh memoinfo.fr 12-2014

# votre domaine, sera passé en paramètre de la commande
SITE=$1
# période, sera passée en paramètre de la commande
PERIODE=$2
# login de votre compte OVH
LOGIN=votre-login-ovh
# mot de passe de votre compte OVH
PASS=votre-mot-de-passe
# Répertoire de destination. Par défaut sur le bureau (mac). Changez pour ce que vous voulez
DOSSIER=$HOME/Desktop/$SITE/$PERIODE

# Créé le dossier qui va récupérer les logs. Etape obligatoire sinon wget retourne une erreur concernant ses logs
echo 'Création du dossier'
mkdir -p $DOSSIER

# Téléchargement des logs via wget avec les options suivantes :
echo 'Téléchargement des logs...'
wget -nv -nd -r -A.gz -P$DOSSIER https://logs.ovh.net/$SITE/logs-$PERIODE/ --http-user=$LOGIN --http-password=$PASS -o $DOSSIER/logs.wget.txt

echo 'terminé'
