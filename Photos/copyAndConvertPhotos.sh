#!/usr/bin/env bash

export CAT="CDRS"
export ORIG="${HOME}/Images/CDRS/6HParisExport/${CAT}_SHARE" #for sharing on DropBox or Drive
export DEST="${HOME}/Images/CDRS/6HParisExport/${CAT}_WEB" #for importing in Google Photos



web_width=1000


if [ -d "$DEST" ]; then
  rm -rf "$DEST"
fi


mkdir -p "$DEST"

for i in $(find ${ORIG} -name "*.JPG"); 
do 
	image_filename=$(basename $i)
	web_image_abspath="${DEST}/${image_filename}"

	echo "copying ${i} to ${DEST}"
	cp -pv $i "${web_image_abspath}"
		
	original_width=$(identify -format "%[fx:w]" $i)
	original_height=$(identify -format "%[fx:h]" $i)
	web_height=$(( ${original_height}*${web_width}/${original_width} ))
	convert "${i}" -resize ${web_width}x${web_height} "${web_image_abspath}"
done
