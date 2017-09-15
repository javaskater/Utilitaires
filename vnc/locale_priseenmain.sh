#!/usr/bin/env bash

export Host="192.168.1.XX"
export Port="postSSH"
export User="USerMaison"
export IdentityFile="$HOME/.ssh/id_dsa"

demarrer_xvnc_server(){
	ssh -i $IdentityFile $User@$Host -p $Port -o PubkeyAcceptedKeyTypes=+ssh-dss "x11vnc -many -rfbauth ~/.vnc_passwd_${User}"
}

se_connecter_en_mode_console(){
	echo "commande passée: ssh -i -o PubkeyAcceptedKeyTypes=+ssh-dss $IdentityFile $User@$Host -p $Port"
	#gnome-terminal -x bash -c "ssh -i $IdentityFile -o PubkeyAcceptedKeyTypes=+ssh-dss $User@$Host -p $Port"
	ssh -i $IdentityFile -o PubkeyAcceptedKeyTypes=+ssh-dss $User@$Host -p $Port
}

demarrer_le_client(){ #ce doit être le Host et le numéro de Display
	vncviewer -passwd ~/vnc_passwd_${User} ${Host}:0 #téléchargés de Drive les fichiers passwd ne sont plus cachés
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
