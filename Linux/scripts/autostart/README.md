# How to use it

## Just point to the .desktop file

### in startup applications menu !!!

* I push it manually as Unity startup applications
  * which the system translated as/to :

``` bash
# the bash.desktop file creation/modification time is the time i used nity startup launcher
jpmena@jpmena-P34:~/.config/autostart$ ll
total 12
drwxrwxr-x  2 jpmena jpmena 4096 août  27 09:38 ./
drwx------ 25 jpmena jpmena 4096 août  27 09:01 ../
-rw-rw-r--  1 jpmena jpmena  307 août  27 09:33 bash.desktop
# The generated content
jpmena@jpmena-P34:~/.config/autostart$ cat bash.desktop
[Desktop Entry]
Type=Application
Exec=/home/jpmena/RIF/Utilitaires/Linux/scripts/autostart/androidDoc.desktop
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[fr_FR]=AndBooks
Name=Script de démarrage
Comment[fr_FR]=Ouvre les Livres Android
Comment=Ouvre Mon environnment de travail Android
#What is the content of the androidDoc.desktop file usedd by that generrated bassh.desktop
##it the file I append to that project as a working example...
jpmena@jpmena-P34:~/.config/autostart$ cat /home/jpmena/RIF/Utilitaires/Linux/scripts/autostart/androidDoc.desktop
[Desktop Entry]
Type=Application
Terminal=true
Name=Android-Docs
Icon=/home/jpmena/RIF/Utilitaires/Linux/scripts/autostart/icon/00-android-4-0_icons.png
Exec=/home/jpmena/RIF/Uusilitaires/Linux/scripts/autostart/readPdfs.sh
Categories=GNOME;GTK;Utility
StartupNotify=true
```

# How to handle  desktop shortcuts!

## see [Ubuntu Help](https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles)
* It recommends the [desktop-file-validate tool]() which explains in my case:

``` bash
jpmena@jpmena-P34:~/RIF/Utilitaires/Linux/scripts/autostart$ desktop-file-validate phpDoc.desktop
phpDoc.desktop: error: value "/home/jpmena/RIF/Uusilitaires/Linux/scripts/autostart/readPdfs.sh /home/jpmena/Documents/Livres/OReilly/Modern_PHP.pdf;/home/jpmena/Documents/Livres/OReilly/Learning_PHP.pdf" for key "Exec" in group "Desktop Entry" contains a reserved character ';' outside of a quote
phpDoc.desktop: error: value "GNOME;GTK;Utility" for string list key "Categories" in group "Desktop Entry" does not have a semicolon (';') as trailing character
```

## an interesting desktop generation [WIKI Archilinx ](https://wiki.archlinux.org/index.php/Desktop_entries)
