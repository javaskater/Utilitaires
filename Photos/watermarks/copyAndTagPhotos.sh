#!/usr/bin/env bash

export CAT="CDRS"
export ORIG="${HOME}/Images/CDRS/6HParis/$CAT"
export DEST="${HOME}/Images/CDRS/6HParisExport/${CAT}_SHARE" #for sharing on DropBox or Drive

export TAG_FILE="$(pwd)/jpmena.png"

COMPOSITE=/usr/bin/composite

if [ -d "$DEST" ]; then
  rm -rf "$DEST"
fi


mkdir -p "$DEST"

for i in $(find ${ORIG} -name "*.JPG"); 
do 
	nom_image=$(basename $i)

	#see: http://www.the-art-of-web.com/system/imagemagick-watermark/
	echo "je tage ${i} avec ${TAG_FILE} et copie le résultat vers ${DEST}"
	$COMPOSITE -compose multiply -gravity SouthEast -geometry +20+20 $TAG_FILE ${i} ${DEST}/$nom_image
done
