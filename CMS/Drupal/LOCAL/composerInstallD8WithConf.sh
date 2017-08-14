#!/usr/bin/env bash

#The drush drupal8 installer drops by himself the database if exists
## Anyway if we need to create ti from scratch, just put true to the following variable
INSTALL_DATABASE="False"

# On http://docs.drush.org/en/master/install/ they note that:
## Drush 9 (coming soon!) only supports one install method.
## It will require that your Drupal site be built with Composer
## ( which is for the coming Drupal8 releases the preferred method ... )
### and Drush be listed as a dependency.

## that script's directory ...
SCRIPT_DIR=$(pwd)

#absolute path of Drupal's instance
DRU_INSTALL_DIR="$HOME/RIF"
DRU_INSTANCE="d8devextranet"

DRU_SOURCES_DIR="${DRU_INSTALL_DIR}/${DRU_INSTANCE}"

DRU_HOME="${DRU_SOURCES_DIR}/web"
DRU_NAME=$(basename $DRU_SOURCES_DIR)

DRU_COMPOSER_MODULES="${DRU_HOME}/modules/contrib"
DRU_PERSONAL_MODULES="${DRU_HOME}/modules/custom"

DRU_THEMES="${DRU_HOME}/themes"

#paramètres demandés par le script d'installation de Drupal
ADMIN_PASSWD="admin"
SITE_NAME="Randonneurs Ile de France"

#paramétrages présents dans le fichier setings.php
##le chemin d'accès aux fichiers plats doit être accessible rwx par www-data
PRIVATE_FILE_IMAGE_PATH="$HOME/Images/RIF"
##le proxy DGFIP qui permet à Drupal d'accéder à internet (mises à jour, installation de modules par l'interface graphique ?)
PROXY="http://monproxy:monport"

MYSQL_ROOT="root"
MYSQL_ROOTPASSWD="root"
MYSQL_DATABASE=$DRU_INSTANCE

DIR=${PWD%/}
DAT=$(date +%Y%m%d_%H%M%S)
FLOG=$DIR/${DRU_INSTANCE}-$DAT.log
DRUPAL_ARCHIVE=${DRU_INSTALL_DIR}/"${DRU_INSTANCE}-${DAT}"

#for aliases definiton we need...

shopt -s expand_aliases #cf. answer 4 from https://stackoverflow.com/questions/24054154/how-to-create-an-aliases-in-shell-scripts

#before launching that script follow underneath instructions from https://getcomposer.org/download/ to install composer.phar under your $HOME dir:
#those instructions are:
## curl https://getcomposer.org/installer -o composer-setup.php
## php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
## php composer-setup.php
## php -r "unlink('composer-setup.php');"
# now that composer.phar is under $HOME, I can define the following alias :
alias local_composer="php $HOME/composer.phar"

#once Drupal will have been installed by composer, we have to define the following alias ...
## which can be used only when we are under $DRU_HOME
alias local_drush="php ../vendor/drush/drush/drush.php"


function mysql_database_creation(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
mysql -u${MYSQL_ROOT} -p${MYSQL_ROOTPASSWD} -h localhost  2>&1 <<EOF
DROP DATABASE IF EXISTS ${MYSQL_DATABASE};
DROP USER IF EXISTS ${MYSQL_DATABASE}@localhost;
CREATE USER '${MYSQL_DATABASE}'@'localhost' IDENTIFIED BY '${MYSQL_DATABASE}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_DATABASE}\`@localhost;
EOF
    resmysql=$?
}

function kernel(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    old_dir=$(pwd)

    echo "We install the latest Drupal8 sources unser ${DRU_SOURCES_DIR} unsig composer"
    sudo rm -rf $DRU_SOURCES_DIR
    cd $DRU_INSTALL_DIR
    local_composer create-project drupal-composer/drupal-project:8.x-dev $DRU_INSTANCE --stability dev --no-interaction 2>&1
    echo "we now launch Drupal automatic installation using the local drush present in the vendor directory"
    #you have to be under DRUPAL root to launch our drush commands
    cd $DRU_HOME
    # Some remarks about the site-install (si) drush command:
    ## that command drop the existing Drupal Tables in the Database if necessary  !!!!
    ## Here we chose the standard profile.
    ### the possible profiles match the directories' names present under $DRU_HOME/web/core/profiles
    local_drush si -y --notify --db-url="mysql://${MYSQL_DATABASE}:${MYSQL_DATABASE}@127.0.0.1:3306/${MYSQL_DATABASE}" standard --site-name="$SITE_NAME" --account-pass="$ADMIN_PASSWD" 2>&1

    cd $old_dir
}

function complementary_modules(){
   echo "calling the  $0 / ${FUNCNAME[0]} function"

   #We have to download module code using composer, because Drupal's kernel itself has been downloaded using composer

   MEDIA_ENTITY_DRUSH="media_entity_image"
   MEDIA_ENTITY_COMPOSER="drupal/${MEDIA_ENTITY_DRUSH}"

   old_dir=$(pwd)

   #composer.json (created by the composer download of drupal sources), is present at $DRU_SOURCES_DIR
   ##we need to change directory there to complement it with our required complmentary modules ...
   cd "$DRU_SOURCES_DIR"
   echo "+ we need $MEDIA_ENTITY_COMPOSER (we download it using composer)"
   echo "we are at: $(pwd)"
   local_composer require $MEDIA_ENTITY_COMPOSER 2>&1

   #you have to be under DRUPAL root to launch our drush commands
   cd "${DRU_HOME}"
   echo "+ we activate $MEDIA_ENTITY_DRUSH (and its dependencies)"
   local_drush en -y $MEDIA_ENTITY_DRUSH 2>&1

   cd $old_dir
}

function developper_modules(){
   echo "calling the  $0 / ${FUNCNAME[0]} function"

   #We have to download module code using composer, because Drupal's kernel itself has been downloaded using composer


   #Getting the active configuration key-values pairs on your admin dasboard
   CONFIG_INSPECT_DRUSH="config_inspector"
   CONFIG_INSPECT_COMPOSER="drupal/${CONFIG_INSPECT_DRUSH}"


   #changing user without having to logout and login again
   MASQUERADE_DRUSH="masquerade"
   MASQUERADE_COMPOSER="drupal/${MASQUERADE_DRUSH}"

   #Developpers' tools suite ...
   DEVEL_DRUSH="devel"
   DEVEL_COMPOSER="drupal/${DEVEL_DRUSH}"
   ##We will use  DEVEL_GENERATE from the suite for automatically generating content of any content type
   DEVEL_GENERATE_DRUSH="devel_generate"
   ##We will use  DEVEL_GENERATE from the suite for graphically twig debugging using the 'kint($my_variable);' command
   DEVEL_KINT_DRUSH="kint"
   ##We will use  WEPROFILER from the suite to get a developper's ToolBar at the bottom of the screen, analogous to the  Symfony app_dev.php toolbar
   DEVEL_WEBPROFILER_DRUSH="webprofiler"

   #We will use EXAMPLES from the suite to get a Suite of well written modules (each modules does only one thing and does it well)
   EXAMPLES_DRUSH="examples"
   EXAMPLES_COMPOSER="drupal/${EXAMPLES_DRUSH}"

   #composer.json (created by the composer download of drupal sources), is present at $DRU_SOURCES_DIR
   ##we need to change directory there to complement it with our required complmentary modules...

   old_dir=$(pwd)

   cd "$DRU_SOURCES_DIR"

   echo "+ we need $CONFIG_INSPECT_COMPOSER (we download it using composer)"
   local_composer require $CONFIG_INSPECT_COMPOSER 2>&1

   echo "+ we need $DEVEL_COMPOSER (we download it using composer)"
   local_composer require $DEVEL_COMPOSER 2>&1

   echo "+ we need $EXAMPLES_COMPOSER (we download it using composer)"
   local_composer require $EXAMPLES_COMPOSER 2>&1

   echo "+ we need $MASQUERADE_COMPOSER (we download it using composer)"
   local_composer require $MASQUERADE_COMPOSER 2>&1

   #you have to be under DRUPAL root to launch our drush commands
   cd "${DRU_HOME}"

   echo "+ we activate $CONFIG_INSPECT_DRUSH (and its dependencies)"
   local_drush en -y $CONFIG_INSPECT_DRUSH 2>&1

   echo "+ we activate $DEVEL_GENERATE_DRUSH (and its dependencies)"
   local_drush en -y $DEVEL_GENERATE_DRUSH 2>&1

   echo "+ we activate $DEVEL_KINT_DRUSH (and its dependencies)"
   local_drush en -y $DEVEL_KINT_DRUSH 2>&1

   echo "+ we activate $DEVEL_WEBPROFILER_DRUSH (and its dependencies)"
   local_drush en -y $DEVEL_WEBPROFILER_DRUSH 2>&1

   echo "+ we activate $EXAMPLES_DRUSH (and its dependencies)"
   local_drush en -y $EXAMPLES_DRUSH 2>&1

   echo "+ we activate $MASQUERADE_DRUSH (and its dependencies)"
   local_drush en -y $MASQUERADE_DRUSH 2>&1

   cd $old_dir
}

function personal_devs(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"

    old_dir=$(pwd)

    IMPORT_MODULE="rif_imports"

    #my module need the following  one that I have to download via composer before enabling the whole
    DELETE_ALL_DRUSH="delete_all"
    DELETE_ALL_COMPOSER="drupal/${DELETE_ALL_DRUSH}"

    cd "$DRU_SOURCES_DIR"

    echo "+ we need ${DELETE_ALL_DRUSH} (we download it using composer)"
    local_composer require $DELETE_ALL_COMPOSER 2>&1

    GIT_IMPORT_MODULE="https://github.com/javaskater/${IMPORT_MODULE}.git"
    echo "+ we clone $GIT_IMPORT_MODULE into $DRU_PERSONAL_MODULES"
    mkdir $DRU_PERSONAL_MODULES && cd $DRU_PERSONAL_MODULES
    git clone $GIT_IMPORT_MODULE 2>&1
    echo "+ we activate $IMPORT_MODULE and its dependencies (configuration modules)"
    #you have to be under DRUPAL root to launch our drush commands
    cd "$DRU_HOME"
    local_drush en -y $IMPORT_MODULE 2>&1

    cd $old_dir

}

function tunings(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    SETTINGS_FILE="${DRU_HOME}/web/sites/default/settings.php"
    chmod u+w $SETTINGS_FILE
    echo "" >> $SETTINGS_FILE
    echo "/* " >> $SETTINGS_FILE
    echo "* paramètres ajoutés par la fonction ${FUNCNAME[0]} du script $0" >> $SETTINGS_FILE
    echo "*/" >> $SETTINGS_FILE
    #We don't want our attached file be in the public directory by default see  de https://www.drupal.org/node/2392959 (bottom of the webpage)
    echo "\$settings['file_private_path'] = '${PRIVATE_FILE_IMAGE_PATH}';" >> $SETTINGS_FILE
    #If Drupal has to access internet through a proxy server, wee need to add its address here ....
    echo "\$settings['http_client_config']['proxy']['http'] = '${PROXY}';" >> $SETTINGS_FILE
    echo "\$settings['http_client_config']['proxy']['https'] = '${PROXY}';" >> $SETTINGS_FILE
    echo "\$settings['http_client_config']['proxy']['no'] = ['127.0.0.1', 'localhost', '*.dgfip'];" >> $SETTINGS_FILE
    chmod u-w $SETTINGS_FILE
}

function backup_instance(){
    echo "calling the $0 / ${FUNCNAME[0]}"
    archive_name="$(basename $DRUPAL_ARCHIVE)"
    archive_install_dir="$(dirname $DRUPAL_ARCHIVE)"
    
    old_dir=$(pwd)
    cd "$DRU_HOME"
    
    drupal_code_dirname=$DRU_NAME
    
    echo "+ clean up cache before backuping"
    local_drush cr 2>&1
    
    if [ -d "$DRUPAL_ARCHIVE" ]; then
        rm -rf "$DRUPAL_ARCHIVE"
    fi
    mkdir -p "$DRUPAL_ARCHIVE"
    cd "$DRUPAL_ARCHIVE"
    echo "backupin Mysql Database: $MYSQL_DATABASE"
    if mysql -u${MYSQL_ROOT} -p${MYSQL_ROOTPASSWD} -e 'show databases;' 2>/dev/null | grep -i ${MYSQL_DATABASE}; then
        echo "Mysql Database $MYSQL_DATABASE exists, we can backup it"
        mysqldump -u${MYSQL_ROOT} -p${MYSQL_ROOTPASSWD} ${MYSQL_DATABASE} -h localhost > "${MYSQL_DATABASE}.sql"
    else
        echo "Mysql Database $MYSQL_DATABASE does not exists, we cannot backup it. Giving up"
        exit -1
    fi
    echo "Backuping Drupal8 Source Code ...."
    cd $archive_install_dir
    tar czf "${drupal_code_dirname}.tgz" $drupal_code_dirname && mv -v "${drupal_code_dirname}.tgz" $archive_name
    echo "backuping  ${archive_install_dir} as ${archive_name}.tgz"
    tar czf "${archive_name}.tgz" $archive_name -C "${archive_install_dir}" 2>&1
    cd $old_dir

}

function main(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    if [ $INSTALL_DATABASE == "True" ]; then
        mysql_database_creation
    fi
    #kernel
    #complementary_modules
    #developper_modules
    #personal_devs
    #tunings
    backup_instance
}

main | tee $FLOG
