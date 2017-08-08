#!/usr/bin/env bash

export ORIG="~/Images/CDRS/6HParis/PATI"
export DEST="~/Images/CDRS/6HParis/PATI_TAG"

export TAG_FILE="~/Images/jpmena.png"

COMPOSITE=/usr/bin/composite

if [ -d "$DEST" ]; then
  rm -rf "$DEST"
fi


mkdir -p "$DEST"

for i in $(find ${ORIG} -name "*.JPG" -mtime -2); 
do 
	nom_image=$(basename $i)

	#see: http://www.the-art-of-web.com/system/imagemagick-watermark/
	echo "je tage ${i} avec ${TAG_FILE} et copie le résultat vers ${DEST}"
	$COMPOSITE -compose multiply -gravity SouthEast -geometry +5+5 $TAG_FILE ${i} ${DEST}/$nom_image
done
