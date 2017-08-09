# Watermarking using [ImageMagick under Ubuntu](https://doc.ubuntu-fr.org/imagemagick)

## Install of course [ImageMagick under Ubuntu](https://doc.ubuntu-fr.org/imagemagick)

* ImageMagick comes with many bash tools like _display_, _identify_, _convert_, _composite_
  * In my case it had been installed before (so don't mind the output) 

```
jpmena@jpmena-P34:~/Images/CDRS$ sudo apt install imagemagick
Lecture des listes de paquets... Fait
Construction de l'arbre des dépendances       
Lecture des informations d'état... Fait
imagemagick is already the newest version (8:6.8.9.9-7ubuntu5.8).
imagemagick passé en « installé manuellement ».
Les paquets suivants ont été installés automatiquement et ne sont plus nécessaires :
  linux-headers-4.4.0-81 linux-headers-4.4.0-81-generic linux-image-4.4.0-81-generic linux-image-extra-4.4.0-81-generic
Veuillez utiliser « sudo apt autoremove » pour les supprimer.
0 mis à jour, 0 nouvellement installés, 0 à enlever et 47 non mis à jour.
```

## Create the SVG Watermark:

* I used inkscape and followed [Blog page](https://www.pdfannotator.com/en/howto/create_complex_stamps_with_inkscape)

## place the Watermark 
 * I used the ImageMagick __composite__ bash command in that script following that [Blog Post](http://www.the-art-of-web.com/system/imagemagick-watermark/)


## TODO:

### 09/08/2017

* I need to adapt the watermark size to my picture size
  * Is there an option in _composite_ ?
  * Do I need to calculate the svg png export each time ?