#/usr/bin/env bash

#the command to be passed at GNOME at startup
#to be placed in a https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles
## ~/RIF/Utilitaires$ bash /home/jpmena/RIF/Utilitaires/Linux/scripts/autostart/readPdfs.sh "/home/jpmena/Documents/Livres/Informit/9780134401966.pdf;/home/jpmena/Documents/Livres/Informit/9780134171494.pdf"

trace(){
	msg=$1
	timestamp=$(date +%Y/%m/%d-%H:%M:%S)
	echo "$timestamp - $msg"
}

if [ "$#" -eq 1 ]
then
	IN=$1
	
	#trace "we have to open $IN"
else
	IN="/home/jpmena/Documents/Livres/Informit/9780134401966.pdf;/home/jpmena/Documents/Livres/Informit/9780134171494.pdf"
	#trace "Illegal number of parameters found $# parameters, should be 1"
	#trace "Usage: $0 {pdf abs path 1};{pdf abs path 2};...."
	#trace "opens the specified pdf documents (script for startup) ????"
	#trace "the argument is a list of absolute pdf pathes, each path is separated from the next by ';'"
	exit 1
fi

PDFFILES=$(echo $IN | tr ";" "\n")
# Detect paths
PDFREADER=$(which evince)

# the & symbol is mandatory otherwise only a pdf would open and the startup process would block !!!!
main(){
	for arg in $PDFFILES #if you replace with "$PDFFILES" it takes as a unique arg !!! problem 
	do
		if [ -e "$arg" ]
		then
				$PDFREADER $arg &
				if [ $? -eq 0 ]; then
					trace " - result of opening $arg : OK "
				else
					trace " ERROR - result of opening $arg : KO "
					exit 1
				fi
		else
				trace " ERROR - the file $arg does not exist : KO"
				#exit 1
		fi
	done
}

mainargs(){
	for arg in $PDFFILES #if you replace with "$PDFFILES" it takes as a unique arg !!! problem 
	do
		if [ -e "$arg" ]
		then
				trace " OK - the file $arg exists : OK "
		else
				trace " ERROR - the file $arg does not exist : KO"
				#exit 1
		fi
	done
}

main
#mainargs
