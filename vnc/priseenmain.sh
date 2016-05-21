#!/usr/bin/env bash

export Host="xxxx.xxxx.xxxx.xxxx"
export Port="Port Ouvert Pour la Box"
export User="UtilisateurConnecte"
export IdentityFile="$HOME/.ssh/id_dsa"

demarrer_xvnc_server(){
	ssh -i $IdentityFile $User@$Host -p $Port -o PubkeyAcceptedKeyTypes=+ssh-dss<<EOF
	x11vnc -many -rfbauth ~/.vnc_passwd
EOF
}

se_connecter_en_mode_console(){
	echo "commande passée: ssh -i -o PubkeyAcceptedKeyTypes=+ssh-dss $IdentityFile $User@$Host -p $Port"
	gnome-terminal -x bash -c "ssh -i $IdentityFile -o PubkeyAcceptedKeyTypes=+ssh-dss $User@$Host -p $Port"
}

demarrer_le_client(){
	gnome-terminal -x bash -c "ssh -p 9222 -X -L 5900:localhost:5900 -o PubkeyAcceptedKeyTypes=+ssh-dss ${Host}"
	sleep 5
	xvnc4viewer localhost:5900
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
		echo "options possibles: s pour démarrer le serveur distant xvnc, v pour démarrer le client vnc en local, l pour acceder en ssh au serveur distant"
	fi
}

main $@
