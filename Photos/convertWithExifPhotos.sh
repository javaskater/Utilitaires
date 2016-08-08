#!/bin/bash

export ORIG_BASE=~/Images/RSM/6HeuresParis2016
export ARCHIVE_BASE=~/RSM
export base_name=6HParis2016Selection
if [ -d ${ARCHIVE_BASE}/${base_name} ]; then
  	echo "suppression ${ARCHIVE_BASE}/${base_name}"
	#* pour supprimer aussi l'archive !!!
	rm -rf "${ARCHIVE_BASE}/${base_name}*"
fi
export largeur_reduite=800
export ORIG=${ORIG_BASE}/${base_name}
#http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for abs_path_image in $(find ${ORIG} -type f -name "*.JPG")
#for i in $(ls -l ${ORIG} | grep -i '\.jpg' | sed -e 's/  */ /gi' | cut -d ' ' -f9- | sort); 
do 
	#J'obtiens la largeuret hauteur le tout en pixels
	#image_source=$ORIG/$i
        echo "je decode ${abs_path_image}"
	archive_dirs=$(basename $(dirname $(dirname $abs_path_image)))/$(basename $(dirname $abs_path_image))
	if [ ! -d ${ARCHIVE_BASE}/${archive_dirs} ]; then
  		echo "-répertoire à créer ${ARCHIVE_BASE}/${archive_dirs}"
		mkdir -p ${ARCHIVE_BASE}/${archive_dirs}
	fi
		
	largeur_originale=$(identify -format "%[fx:w]" ${abs_path_image})
	hauteur_originale=$(identify -format "%[fx:h]" ${abs_path_image})
	hauteur_reduite=$(( ${largeur_reduite}*$hauteur_originale/$largeur_originale ))
	echo "- largeur nouvelle: ${hauteur_reduite}"
	nom_image=$(basename ${abs_path_image}):
	echo "-- le nom de l'image correspondante est ${nom_image}"
	convert "${abs_path_image}" -resize ${largeur_reduite}x${hauteur_reduite} "${ARCHIVE_BASE}/${archive_dirs}/${nom_image}"
	#description=$(exiftool  "${SAUV_BASE}/${base_name}/${nom_image}" -xmp:all | grep -i title | cut -d':' -f2 | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g')
	#echo "${i} a pour commentaire ${description}"
	#if [ -z "$description" ]
	#then
	#	echo "${nom_image}|xxxxxxxxxxxxxxxx|yyyyyyyyyy" >> "${ARCHIVE_BASE}/${base_name}/labels.txt"
	#else
	#	echo "${nom_image}|${description}|yyyyyyyyyy" >> "${ARCHIVE_BASE}/${base_name}/labels.txt"
	#fi
done
act_rep=$(pwd)
cd $ARCHIVE_BASE
zip -r "${base_name}.zip" ${base_name}
cd $act_rep
# restore $IFS
IFS=$SAVEIFS
