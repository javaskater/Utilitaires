#!/usr/bin/env bash

#The drush drupal8 installer drops by himself the database if exists
## Anyway if we need to create ti from scratch, just put true to the following variable
INSTALL_DATABASE="True"
LOCALE="fr"
# On http://docs.drush.org/en/master/install/ they note that:
## Drush 9 (coming soon!) only supports one install method.
## It will require that your Drupal site be built with Composer
## ( which is for the coming Drupal8 releases the preferred method ... )
### and Drush be listed as a dependency.

## that script's directory ...
SCRIPT_DIR=$(pwd)
USER=$(whoami)
APACHE="www-data"

#absolute path of Drupal's instance
DRU_INSTALL_DIR="$HOME/RIF"
DRU_INSTANCE="d8devextranet"

DRU_SOURCES_DIR="${DRU_INSTALL_DIR}/${DRU_INSTANCE}"

DRU_HOME="${DRU_SOURCES_DIR}/web"
DRU_NAME=$(basename $DRU_SOURCES_DIR)

DRU_COMPOSER_MODULES="${DRU_HOME}/modules/contrib"
DRU_PERSONAL_MODULES="${DRU_HOME}/modules/custom"

DRU_THEMES="${DRU_HOME}/themes"

# parameters required by the Drupal installation script
ADMIN_PASSWD="admin"
SITE_NAME="Randonneurs Ile de France"

# Adding parameters to the default settings.php file
## the path to the private files/medias must be  rwx for www-data
### uncomment the following variable if you put your images/files in a private location (not public like default)
#PRIVATE_FILE_IMAGE_PATH="$HOME/Images/RIF"
## The Proxy server for Drupal to access internet (updates, localisation updates, adding module through GUI)
### uncomment the following variable (and change for the right parameters) if your Drupal installation stays behind such a proxy server
#PROXY="http://proxy.mycompany:itsport"

MYSQL_ROOT="root"
MYSQL_ROOTPASSWD="root"
MYSQL_DATABASE=$DRU_INSTANCE

DIR=${PWD%/}
DAT=$(date +%Y%m%d_%H%M%S)
FLOG="$DIR/${DRU_INSTANCE}-$DAT.log"
DRUPAL_ARCHIVE="${DRU_INSTALL_DIR}/${DRU_INSTANCE}-${DAT}"

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
##the local drush command
alias local_drush="php ../vendor/drush/drush/drush.php"
#une fois la console drupal installée localement par composer (partie vendor), on pourra passer la commande :
## attention les commmandes de la console se passent depuis le répertoire des sources
## et non depuis le sous-répertoire web !!!
alias local_drupal="php vendor/drupal/console/bin/drupal.php"


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

    if [ -d "$DRU_SOURCES_DIR" ]; then
    	echo "+ ${DRU_SOURCES_DIR} exists (prvious installation), we supress those old sources before getting the new ones"
        sudo rm -rf $DRU_SOURCES_DIR
    fi
    
    echo "We install the latest Drupal8 sources unser ${DRU_SOURCES_DIR} unsig composer"
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

function add_another_language(){
    newlang=$1 # must be fr or de or es see https://docs.drupalconsole.com/en/commands/locale-language-add.html
    echo "calling the $0 / ${FUNCNAME[0]} function for adding ${newlang} to Drupal"
    LOCALE_DRUSH="locale"
	old_dir=$(pwd)
	cd "${DRU_HOME}"
	#In the case of an automatic installation this module is not active by default
	echo " -- activating the $LOCALE_DRUSH module present but not activated by default"
	local_drush en -y ${LOCALE_DRUSH} 2>&1
	cd "${DRU_SOURCES_DIR}"
	echo " - adding the ${newlang} as Drupal interface language"
	#see. https://docs.drupalconsole.com/en/commands/locale-language-add.html
	local_drupal ${LOCALE_DRUSH}:language:add ${newlang} 2>&1
    echo " - rebuilding the cache..."
    cd "${DRU_HOME}"
    local_drush cr 2>&1
    cd ${old_dir}
}

function set_language_as_default(){
    default_lang=$1 # must be fr or de or es see https://docs.drupalconsole.com/en/commands/locale-language-add.html
    echo "calling the $0 / ${FUNCNAME[0]} function for setting ${default_lang} as the Drupal default language"
	old_dir=$(pwd)
	cd "$DRU_SOURCES_DIR"
    echo " - settig ${newlang} as the default Drupal interface language"
    local_drupal co system.site langcode ${default_lang} 2>&1
    local_drupal co system.site default_langcode ${default_lang} 2>&1
    echo " - rebuilding the cache..."
    cd "${DRU_HOME}"
    local_drush cr 2>&1
    cd ${old_dir}
}

function update_interface_translations(){
    echo "calling the $0 / ${FUNCNAME[0]} function"
    LOCALE_DRUSH="locale"
	old_dir=$(pwd)
	cd "${DRU_HOME}"
	local_drush locale-check 2>&1
	local_drush locale-update 2>&1
	local_drush cr
    cd ${old_dir}
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

   #delete all users or all entities of a specific content type
   DELETE_ALL_DRUSH="delete_all"
   DELETE_ALL_COMPOSER="drupal/${DELETE_ALL_DRUSH}"

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

   echo "+ we need $DELETE_ALL_COMPOSER (we download it using composer)"
   local_composer require $DELETE_ALL_COMPOSER 2>&1

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

   echo "+ we activate $DELETE_ALL_DRUSH (and its dependencies)"
   local_drush en -y $DELETE_ALL_DRUSH 2>&1

   cd $old_dir
}

function personal_devs(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"

    old_dir=$(pwd)

    IMPORT_MODULE="rif_imports"

    cd "$DRU_SOURCES_DIR"

    GIT_IMPORT_MODULE="https://github.com/javaskater/${IMPORT_MODULE}.git"
    echo "+ we clone $GIT_IMPORT_MODULE into $DRU_PERSONAL_MODULES"
    mkdir $DRU_PERSONAL_MODULES && cd $DRU_PERSONAL_MODULES
    git clone $GIT_IMPORT_MODULE 2>&1
    
    #you have to be under DRUPAL root to launch our drush commands
    cd "$DRU_HOME"
    echo "+ we activate $IMPORT_MODULE and its dependencies (configuration modules)"
    local_drush en -y $IMPORT_MODULE 2>&1

    cd $old_dir
}

function featuring(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"

    old_dir=$(pwd)

    #my module need the following  one that I have to download via composer before enabling the whole
    FEATURES_DRUSH="features"
    FEATURES_UI_DRUSH="${FEATURES_DRUSH}_ui"
    FEATURES_COMPOSER="drupal/${FEATURES_DRUSH}"

    cd "$DRU_SOURCES_DIR"

    echo "+ we need ${FEATURES_DRUSH} (we download it using composer)"
    local_composer require $FEATURES_COMPOSER 2>&1
    
    #you have to be under DRUPAL root to launch our drush commands
    cd "$DRU_HOME"
    echo "+ we then activate ${FEATURES_DRUSH} using drush"
    local_drush en -y $FEATURES_DRUSH 2>&1
    echo "+ we then activate ${FEATURES_UI_DRUSH} using drush"
    local_drush en -y $FEATURES_UI_DRUSH 2>&1


    cd $old_dir

}


#the kernel search module makes Drupal wuse intesively the Database
#for our dev environment we need to deactivate it .
function search_deactivate(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"

    old_dir=$(pwd)

    #the kernel search module
    SEARCH_DRUSH="search"

    #you have to be under DRUPAL root to launch our drush commands
    cd "$DRU_HOME"
    local_drush pm-uninstall -y $SEARCH_DRUSH 2>&1

    cd $old_dir

}

function drupal_themings(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"

    old_dir=$(pwd)

    #Main Drupal8 frontend theme based on Bootstrap (comes with a Starter Kit)
    BOOTSTRAP_THEME_DRUSH="bootstrap"
    BOOTSTRAP_THEME_COMPOSER="drupal/${BOOTSTRAP_THEME_DRUSH}"

    #lightweight backend theme 
    ## To avoid conflict between the default admin toolbar and the adminimal admin toolbar we need the followinc module
    ### see. explanations on https://www.drupal.org/project/adminimal_admin_toolbar 
    ADMINIMAL_TOOLBAR_DRUSH="adminimal_admin_toolbar"
    ADMINIMAL_TOOLBAR_COMPOSER="drupal/${ADMINIMAL_TOOLBAR_DRUSH}"
    ADMINIMAL_THEME_DRUSH="adminimal_theme"
    ADMINIMAL_THEME_COMPOSER="drupal/${ADMINIMAL_THEME_DRUSH}"

    cd "$DRU_SOURCES_DIR"

    echo "+ we need ${BOOTSTRAP_THEME_DRUSH} (we download it using composer)"
    local_composer require $BOOTSTRAP_THEME_COMPOSER 2>&1


    echo "+ we need ${ADMINIMAL_TOOLBAR_DRUSH} (we download it using composer)"
    local_composer require $ADMINIMAL_TOOLBAR_COMPOSER 2>&1
    echo "+ we need ${ADMINIMAL_THEME_DRUSH} (we download it using composer)"
    local_composer require $ADMINIMAL_THEME_COMPOSER 2>&1

    cd "$DRU_HOME"
    
    echo "+ we activate $BOOTSTRAP_THEME_DRUSH"
    local_drush en -y $BOOTSTRAP_THEME_DRUSH 2>&1
    echo "+ we activate $ADMINIMAL_THEME_DRUSH"
    local_drush en -y $ADMINIMAL_THEME_DRUSH 2>&1
    echo "+ we activate $ADMINIMAL_TOOLBAR_DRUSH"
    local_drush en -y $ADMINIMAL_TOOLBAR_DRUSH 2>&1

    ## vset does not work in Drupal 8, instead we have to cchange the cconfiguration
    ## defined at http://d8devextranet.ovh/admin/config/development/configuration/inspect/system.theme/raw
    ## unsing drupal cconsole ...
    cd "$DRU_SOURCES_DIR"
    echo "+ we define $BOOTSTRAP_THEME_DRUSH as the default frontend theme"
    local_drupal co system.theme default $BOOTSTRAP_THEME_DRUSH 2>&1
    echo "+ we define $ADMINIMAL_THEME_DRUSH as the default backend theme"
    local_drupal co system.theme admin $ADMINIMAL_THEME_DRUSH 2>&1

    cd "$DRU_HOME"
    local_drush cr 2>&1

    cd $old_dir
}

function tunings(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    SETTINGS_FILE="${DRU_HOME}/sites/default/settings.php"
    chmod u+w $SETTINGS_FILE
    echo "" >> $SETTINGS_FILE
    echo "/* " >> $SETTINGS_FILE
    echo "* paramètres ajoutés par la fonction ${FUNCNAME[0]} du script $0" >> $SETTINGS_FILE
    echo "*/" >> $SETTINGS_FILE
    #We don't want our attached file be in the public directory by default see  de https://www.drupal.org/node/2392959 (bottom of the webpage)
    if [ -n "${PRIVATE_FILE_IMAGE_PATH}" ]
    then
        echo "\$settings['file_private_path'] = '${PRIVATE_FILE_IMAGE_PATH}';" >> $SETTINGS_FILE
    fi
    #If Drupal has to access internet through a proxy server, wee need to add its address here ....
    if [ -n "${PROXY}" ]
    then
        echo "\$settings['http_client_config']['proxy']['http'] = '${PROXY}';" >> $SETTINGS_FILE
        echo "\$settings['http_client_config']['proxy']['https'] = '${PROXY}';" >> $SETTINGS_FILE
        echo "\$settings['http_client_config']['proxy']['no'] = ['127.0.0.1', 'localhost', '*.dgfip'];" >> $SETTINGS_FILE
    fi
    chmod u-w $SETTINGS_FILE
}

function display_drupal_available_console_commands(){
    echo "calling the $0 / ${FUNCNAME[0]}"
    old_dir=$(pwd)

    cd "${DRU_HOME}"
    echo "1/ displaying the list of available drush commands:"
    local_drush help 2>&1
    # attention les commmandes de la console se passent depuis le répertoire des sources
    ## et non depuis le sous-répertoire web !!!
    cd "${DRU_SOURCES_DIR}"
    echo "2/ on affiche la liste des commandes proposées par la console Drupal:"
    local_drupal list 2>&1

    cd $old_dir
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
    old_dir=$(pwd)
    if [ $INSTALL_DATABASE == "True" ]; then
        mysql_database_creation
    fi
    kernel
    search_deactivate
    add_another_language ${LOCALE}
    set_language_as_default ${LOCALE}
    complementary_modules
    drupal_themings
    developper_modules
    personal_devs
    featuring
    tunings
    update_interface_translations
    display_drupal_available_console_commands
    backup_instance
    cd "$DRU_HOME"
    local_drush cr 2>&1
    sudo chown -R $USER:$APACHE $DRU_HOME 2>&1
    sudo chmod -R g+w $DRU_HOME 2>&1
    cd $old_dir
}

main | tee $FLOG
