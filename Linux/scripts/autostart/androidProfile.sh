#/usr/bin/env bash

#the command to be passed at GNOME at startup
## sh /home/jpmena/RIF/Utilitaires/Linux/scripts/autostart/androidProfile.sh /home/jpmena/Documents/Livres/Informit/eBook/9780134401966.pdf /home/jpmena/Documents/Livres/Informit/eBook/9780134171494.pdf
##don't use neither ~ nor $HOME those variables belong to the shell and GNOME does not know them !!!!

# the & symbol is mandatory otherwise only a pdf would open and the startup process would block !!!!
for arg in "$@"
do
    evince $arg &
done

#starting Android Studio !!!!
ASTUDIO_HOME=$HOME/Ateliers/android-studio

$ASTUDIO_HOME/bin/studio.sh &
