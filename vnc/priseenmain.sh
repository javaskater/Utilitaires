#!/usr/bin/env bash

export Host="IP Box Sabalos"
export Port="PortSSH"
export User="userSabalos"
export IdentityFile="$HOME/.ssh/id_dsa"

demarrer_xvnc_server(){
	ssh -i $IdentityFile $User@$Host -p $Port -o PubkeyAcceptedKeyTypes=+ssh-dss "x11vnc -many -rfbauth ~/.vnc_passwd_${User}"
}

se_connecter_en_mode_console(){
	echo "commande passée: ssh -i -o PubkeyAcceptedKeyTypes=+ssh-dss $IdentityFile $User@$Host -p $Port"
	#gnome-terminal -x bash -c "ssh -i $IdentityFile -o PubkeyAcceptedKeyTypes=+ssh-dss $User@$Host -p $Port"
	ssh -i $IdentityFile -o PubkeyAcceptedKeyTypes=+ssh-dss $User@$Host -p $Port
}

demarrer_le_client(){
	gnome-terminal -x bash -c "ssh -p 9222 -X -L 5900:localhost:5900 -o PubkeyAcceptedKeyTypes=+ssh-dss ${Host}"
	sleep 5
	#ce doit être le Host et le numéro de Display (Le serveur nous indique 0)
	## le port est 5900 et ne doit pas être utilisé par un serveur localhost
	### pour savoir qui l'utilise lsof -ti:5900
	#téléchargés de Drive les fichiers passwd ne sont plus cachés
	vncviewer -passwd ~/vnc_passwd_${User} localhost:0
}

main(){
	option=$1
	echo "option vaut $option"
	if [ "$option" = "s" ]
	then
		echo "On démarrer le serveur VNC chez l'hote $Host et l'utilisateur $User"
		demarrer_xvnc_server
	elif [ "$option" = "c" ]
	then
		echo "On démarre le client VNC en local"
		demarrer_le_client
	elif [ "$option" = "l" ]
	then
		echo "On accède à l'hote $Host et l'utilisateur $User en ssh simple"
		se_connecter_en_mode_console
	else
		echo "options possibles: s pour démarrer le serveur distant xvnc, c pour démarrer le client vnc en local, l pour acceder en ssh au serveur distant"
	fi
}

main $@
