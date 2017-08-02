#!/usr/bin/env bash


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


#le drush installer supprime lui même la base si elle existe ...
## ce paramètre permet notamment de la créer si elle n'exite pas
## la base portera le nom de la racine Drupal (ici d8postedev même nom pour l'utilisateur) 
INSTALL_DATABASE="True"

PG_DATABASE=$DRU_INSTANCE

DIR=${PWD%/}
DAT=$(date +%Y%m%d_%H%M%S)
FLOG=$DIR/${DRU_NAME}-$DAT.log

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


function postgres_database_creation(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -iw $PG_DATABASE; then
        echo "The Database $PG_DATABASE does exist, we suppress it before creating it again..."
        echo "- we suppress the $PG_DATABASE database"
        sudo -u postgres dropdb $PG_DATABASE 2>&1
        echo "- we suppress the $PG_DATABASE user"
        sudo -u postgres dropuser $PG_DATABASE 2>&1
        echo "- after having deleted it, we create ${PG_DATABASE} again!"
    else
        echo "The Database $PG_DATABASE does not exist, we just create it, along with its associated user"
    fi
    #We create a Postgres User with password same as name!
    sudo -u postgres psql -c "CREATE USER $PG_DATABASE WITH PASSWORD '$PG_DATABASE';" 2>&1
    #We now create the database having the same name as the user just created
    sudo -u postgres createdb -O $PG_DATABASE $PG_DATABASE 2>&1
}

function kernel(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    old_dir=$(pwd) 

    echo "We install the latest Drupal8 sources unser ${DRU_SOURCES_DIR} unsig composer"
    sudo rm -rf $DRU_SOURCES_DIR
    cd $DRU_INSTALL_DIR
    local_composer create-project drupal-composer/drupal-project:8.x-dev $DRU_HOME --stability dev --no-interaction 2>&1
    echo "we now launch Drupal automatic installation using the local drush present in the vendor directory"
    #you have to be under DRUPAL root to launch our drush commands
    cd $DRU_HOME
    # Some remarks about the site-install (si) drush command:
    ## that command drop the existing Drupal Tables in the Database if necessary  !!!!
    ## Here we chose the standard profile.
    ### the possible profiles match the directories' names present under $DRU_HOME/web/core/profiles
    local_drush si -y --notify --db-url="pgsql://${PG_DATABASE}:${PG_DATABASE}@127.0.0.1:5432/${PG_DATABASE}" standard --site-name="$SITE_NAME" --account-pass="$ADMIN_PASSWD" 2>&1
    
    cd $old_dir
}

function complementary_modules(){
   echo "calling the  $0 / ${FUNCNAME[0]} function"
   
   #We have to download module code using composer, because Drupal's kernel itself has been downloaded using composer
   
   MEDIA_ENTITY_DRUSH="media_entity_image"
   MEDIA_ENTITY_COMPOSER="drupal/${MEDIA_ENTITY_DRUSH}"
   
   
   #composer.json (created by the composer download of drupal sources), is present at $DRU_SOURCES_DIR 
   ##we need to change directory there to complement it with our required complmentary modules ...
   cd "$DRU_SOURCES_DIR"
   echo "+ we need $MEDIA_ENTITY_COMPOSER (we download it using composer)"
   local_composer require $MEDIA_ENTITY_COMPOSER 2>&1
   
   #you have to be under DRUPAL root to launch our drush commands
   cd "${DRU_HOME}"
   echo "+ we activate $MEDIA_ENTITY_DRUSH (and its dependencies)"
   local_drush en -y $MEDIA_ENTITY_DRUSH 2>&1
}

function developper_modules(){
   echo "calling the  $0 / ${FUNCNAME[0]} function"
    
   #We have to download module code using composer, because Drupal's kernel itself has been downloaded using composer
   

   #module de lecture de données de configuration
   CONFIG_INSPECT_DRUSH="config_inspector"
   CONFIG_INSPECT_COMPOSER="drupal/${CONFIG_INSPECT_DRUSH}"


   #module de lecture de données de configuration
   MASQUERADE_DRUSH="masquerade"
   MASQUERADE_COMPOSER="drupal/${MASQUERADE_DRUSH}"
   
   #Suite d'outils pous les développeurs, 
   DEVEL_DRUSH="devel"
   DEVEL_COMPOSER="drupal/${DEVEL_DRUSH}"
   ##nous utiliserons  DEVEL_GENERATE pour l'ajout de données
   DEVEL_GENERATE_DRUSH="devel_generate"
   ##nous utiliserons le module inclu KINT pour le débohgage Twig
   DEVEL_KINT_DRUSH="kint"
   ##nous utiliserons le module inclu WEPROFILER (Barre d'outil au bas de l'écran d'aministrateur Drupal à l'image de la barre Symfony app_dev.php)
   DEVEL_WEBPROFILER_DRUSH="webprofiler"

   #les exemples de modules sur lesquels Mikaël s'appuie pour son stage sont un projet Drupal
   EXAMPLES_DRUSH="examples"
   EXAMPLES_COMPOSER="drupal/${EXAMPLES_DRUSH}"
   
   #composer.json (created by the composer download of drupal sources), is present at $DRU_SOURCES_DIR 
   ##we need to change directory there to complement it with our required complmentary modules...
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
}

function personal_devs(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    old_dir=$(pwd)
    IMPORT_MODULE="rif_imports"
    GIT_IMPORT_MODULE="https://github.com/javaskater/${IMPORT_MODULE}.git"
    echo "+ we clone $GIT_IMPORT_MODULE into $DRU_PERSONAL_MODULES"
    cd $DRU_PERSONAL_MODULES
    git clone $GIT_IMPORT_MODULE
    echo "+ we activate $IMPORT_MODULE and its dependencies (configuration modules)"
    #you have to be under DRUPAL root to launch our drush commands
    cd "$DRU_HOME"
    local_drush en -y $IMPORT_MODULE
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
    #on met à jour le chemin d'accès aux pièces jointes cf. bas de https://www.drupal.org/node/2392959
    echo "\$settings['file_private_path'] = '${PRIVATE_FILE_IMAGE_PATH}';" >> $SETTINGS_FILE
    #on ajoute le proxy DGFIP à notre installation ....
    echo "\$settings['http_client_config']['proxy']['http'] = '${PROXY}';" >> $SETTINGS_FILE
    echo "\$settings['http_client_config']['proxy']['https'] = '${PROXY}';" >> $SETTINGS_FILE
    echo "\$settings['http_client_config']['proxy']['no'] = ['127.0.0.1', 'localhost', '*.dgfip'];" >> $SETTINGS_FILE
    chmod u-w $SETTINGS_FILE
}

function backup_instance(){
    echo "TODO $0 / ${FUNCNAME[0]}"
     
}

function main(){
    echo "calling the  $0 / ${FUNCNAME[0]} function"
    if [ $INSTALL_DATABASE == "True" ]; then
        postgres_database_creation
    fi
    kernel_install
    complementary_modules
    developper_modules
    personal_devs
    #tunings
    backup_instance
}
        
main | tee $FLOG 