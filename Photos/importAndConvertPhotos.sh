#!/usr/bin/env bash

#export ORIG=/media/jpmena/EOS_DIGITAL/DCIM/101D3100
#export ORIG=/run/media/jpmena/D620-F2F8/DCIM/103_PANA
export ORIG=/media/jpmena/DD19-6FC4/DCIM/100NCD40/
export SAUV_BASE=~/Images/Perso
export ARCHIVE_BASE=~/Public


base_name='SaintMichelBraspart02042016'
mini_base_name="mini_${base_name}"
largeur_reduite=1000
mkdir -p "${SAUV_BASE}/${base_name}"
#ORIG=${SAUV_BASE}/${base_name}
mkdir -p "${ARCHIVE_BASE}/${mini_base_name}"
rm -rf "${ARCHIVE_BASE}/${base_name}/*"
for i in $(find ${ORIG} -name "*.JPG" -mtime -2); 
do 
	nom_image=$(basename $i)	

	echo "je copie ${i} vers ${SAUV_BASE}/${base_name}"
	cp -pv $i "${SAUV_BASE}/${base_name}/${nom_image}"
	#J'obtiens la largeuret hauteur le tout en pixels      
	echo "je decode ${i}"	
	largeur_originale=$(identify -format "%[fx:w]" $i)
	hauteur_originale=$(identify -format "%[fx:h]" $i)
	hauteur_reduite=$(( ${largeur_reduite}*$hauteur_originale/$largeur_originale ))
	#echo "largeur nouvelle: ${hauteur_reduite}"
	convert "${SAUV_BASE}/${base_name}/${nom_image}" -resize ${largeur_reduite}x${hauteur_reduite} "${ARCHIVE_BASE}/${mini_base_name}/${nom_image}"
	echo "${nom_image}|xxxxxxxxxxxxxxxx|yyyyyyyyyy" >> "${ARCHIVE_BASE}/${mini_base_name}/labels.txt"
done
