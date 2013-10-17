#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import re
import sys
import subprocess
import time


class Lecon:
    def __init__(self, fic_source_ogg, pattern, rep_dest=None):
        self.fic_source_ogg=fic_source_ogg
        self.fic_name_ogg = os.path.basename(fic_source_ogg)
        self.fic_name_mp3 = "{prefix}.mp3".format(prefix=self.fic_name_ogg[:-4])
        self.fic_lecteur_mp3 = None
        if rep_dest is None:
            rep_dest=os.path.dirname(fic_source_ogg)
        self.fic_lecteur_mp3 = os.path.join(rep_dest,self.fic_name_mp3)
        self.p=pattern
        self.num=self.getNumero()
        
    def getNumero(self):
        num=-1
        nums=self.p.findall(self.fic_name_ogg)
        if nums is not None and len(nums)==1:
            try:
                num=float(nums[0])
            except:
                print ("%s\n" %(sys.exc_info()[0]))
        return num
    def transforme_fichier(self,linux_cmd):
        linux_cmd.append(self.fic_source_ogg)
        linux_cmd.append(self.fic_lecteur_mp3)
        ret=subprocess.call(linux_cmd)
        return ret
        #TODO!!!!!
    
    def __repr__(self):
        return "{origine} vers {lecteur}".format(origine=self.fic_name_ogg,lecteur=self.fic_name_mp3)
    
def organise_fichiers(rep_source,rep_dest):
    liste_fichiers_tries=[]
    p=re.compile("([0-9]+).ogg$")
    if os.path.exists(rep_source) and os.path.exists(rep_dest):
        for f in os.listdir(rep_source):
            if len(f) > 4 and f[-4:] == ".ogg":
                l=Lecon(os.path.join(rep_source,f),p,rep_dest)
                liste_fichiers_tries.append(l)
    return sorted(liste_fichiers_tries, key=lambda lecon: lecon.num)

if __name__ == '__main__':
    lecons_triees=organise_fichiers("/home/jpmena/Music/RUSSECD1/HARRAPS/Russe CD1","/media/jpmena/ARCHOS/LANGUES/RUSSE/CD1")
    for l in lecons_triees:
        print "Leçon no:{n} vaut:{lecon}\n".format(n=l.num,lecon=l)
        retour=l.transforme_fichier(["ffmpeg", "-i"])
        if retour==0:
            print "la transformation de {trans} s'est déroulée avec succès".format(trans=l)
        else:
            print "Echec de la transformation de {trans} code retour {r}".format(trans=l,r=retour)
        time.sleep(2)