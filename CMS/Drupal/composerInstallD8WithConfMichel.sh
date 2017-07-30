#!/usr/bin/env bash


# sur http://docs.drush.org/en/master/install/ est noté
## Drush 9 (coming soon!) only supports one install method. 
## It requires that your Drupal 8 site be built with Composer 
### and Drush be listed as a dependency. 
# Conclusion: Drush 9 n'existera que localement (partie vendor de mon Drupal via composer)


DRU_HOME="$HOME/REFBOFIP/formation3"
ADMIN_PASSWD="admin"
SITE_NAME="REFBOFIP"
#le drush installer supprime lui même la base si elle existe ...
INSTALL_DATABASE="True"

DRU_NAME=$(basename $DRU_HOME)
PG_DATABASE=$DRU_NAME

DIR=${PWD%/}
DAT=$(date +%Y%m%d_%H%M%S)
FLOG=$DIR/${DRU_NAME}-$DAT.log

shopt -s expand_aliases #cf. remarque 4 de https://stackoverflow.com/questions/24054154/how-to-create-an-aliases-in-shell-scripts

#après avoir suivi les instructions de https://getcomposer.org/download/ ce qui donne chez moi après m'être placé sous $HOME:
## curl https://getcomposer.org/installer -o composer-setup.php
## php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
## php composer-setup.php
## php -r "unlink('composer-setup.php');"
# je peux définir l'ailias :
alias local_composer="php $HOME/composer.phar"

#une fois drupal installé par composer, on aura ...
alias local_drush="php ../vendor/drush/drush/drush.php"


function installer_aussi_base(){
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -iw $PG_DATABASE; then
        echo "La base $PG_DATABASE existe, on la supprime avant de la creer a nouveau"
        echo "- on supprime la base $PG_DATABASE"
        sudo -u postgres dropdb $PG_DATABASE 2>&1
        echo "- on supprime l'utilisateur $PG_DATABASE"
        sudo -u postgres dropuser $PG_DATABASE 2>&1
        echo "- on recree la base ${PG_DATABASE}"
    else
        echo "La base $PG_DATABASE n'existe pas, on la crée"
        echo "- on cree la base ${PG_DATABASE} ainsi que son utilisateur"
    fi
    #on crée un utilisateur postgres aladin5 avec le même mot de passe
    sudo -u postgres psql -c "CREATE USER $PG_DATABASE WITH PASSWORD '$PG_DATABASE';" 2>&1
    #on crée une base de données aladin5 dont le propriétaire est l'utilisateur postgres de même nom
    sudo -u postgres createdb -O $PG_DATABASE $PG_DATABASE 2>&1
}

function installer_noyau(){
    echo "on installe les sources Drupal sous ${DRU_HOME} (via composer)" 
    sudo rm -rf $DRU_HOME
    local_composer create-project drupal-composer/drupal-project:8.x-dev $DRU_HOME --stability dev --no-interaction 2>&1
    echo "on lance l'installation l'installation de notre site Drupal (via drush)"
    #il faut etre à la racine de Drupal pour passer les commandes qui von bien ...
    cd $DRU_HOME/web
    #il supprime lui même la base Postgres si elle existe !!!!
    ## les profiles sont définis sous $DRU_HOME/web/core/profiles (voir nom des sous-répertoires)
    local_drush si --db-url="pgsql://${PG_DATABASE}:${PG_DATABASE}@127.0.0.1:5432/${PG_DATABASE}" standard --site-name="$SITE_NAME" --account-pass="$ADMIN_PASSWD" 2>&1
}

function installer_modules_complementaires(){
   #cela se passe avec composer et non drush puisque le drupal a été installé via composer ...
   echo "TODO $0 / ${FUNCNAME[0]}"
}

#installer la configuration de Michel exportée via Features
function installer_features(){
   echo "TODO $0 / ${FUNCNAME[0]}"
}

function sauvegarder(){
    echo "TODO $0 / ${FUNCNAME[0]}"
}

function main(){
    if [ $INSTALL_DATABASE == "True" ]; then
        installer_aussi_base
    fi
    installer_noyau
    installer_modules_complementaires
    installer_features
    sauvegarder
}
        
main | tee $FLOG 