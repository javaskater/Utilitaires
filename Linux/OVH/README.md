# Comment l'utiliser

## demander l'aide :

* pour cela appeler le script sans aucun paramètre :
  * le script appelle alors sa méthode _usage _...

``` bash
jpmena@jpmena-P34 ~/RIF/Utilitaires/Linux/OVH (master=) $ ./logOvh.sh
Le nombre de parramètres doit être 4 ou 5
Usage: ./logOvh.sh {URL Site} {Mois récupéré} {Logs User Name} {Logs User Password} {type de logs}
 + URL Site est le nom de domaine du contrat OVH dont on veut réupérerut les logs
 + Logs User Name est le nom utilisateur demandé par l'authentification basique OVH de rrécupération de Logs
 + Logs User Password est le mot de passe associé à l'utilisateur précéddent demandé par l'authentification basique OVH de rrécupération de Logs
+ type de logs est renseigné à
Récupère les fichiers de Logs d'u type donné pour un domaine donné et un mois donné
+ si le 5ème paramètre n'est pas renseigné ou est vide: ce sont les access logs APACHE qui sont récupérées
+ si le 5ème paramètre est renseigné: ce sont les logs OVH qui sont récupérées pour le type en question lequel peut être:
++ error: logs des erreurs apache
++ ftp: logs des tranferts FTP vers/depuis l'hébergement
++ ssh: logs des acccès ssh sur l'hébergement
++ out : logs des acccès TCP sur l'hébergement - à précciser !!!!
++ cron: logs des des tâches planifiées qui ont été déclenchées sur l'hébergement

```

## mon besoin :

### Récupérer les Logs d'erreur APACHE pour le domaine rifrando.asso.fr sur OVH :

* Ce qui donne d'après la sortie _usage_ précédente:
  * {URL Site} : __rifrando.asso.fr__
  * {Mois récupéré} : __08_2016__ pour le mois d'août 2016 !!!!
  * {Logs User Name} {Logs User Password} : mettre les identifiants / mot de passe de votre manager OVH. Voir cette [page d'aide OVH](https://docs.ovh.com/fr/fr/web/hosting/mutualise-consulter-les-statistiques-et-les-logs-de-mon-site/#id3)
  * {type de logs} :
    * __error__ : je veux dans le cas présent les Logs d'erreur du serveur Apache OVH pour le domaine  _rifrando.asso.fr_; les autres valeurs possibles sont :
    * pas de valeur : on récupère les access logs du serveur Apache OVH pour le domaine  _rifrando.asso.fr_
    * __ftp__ : on récupère les logs des tranferts FTP vers/depuis l'hébergement OVH pour le domaine  _rifrando.asso.fr_
    * __ssh__ : on récupère les logs des acccès ssh sur l'hébergement OVH pour le domaine  _rifrando.asso.fr_
    * __out__ : on récupère les logs des acccès TCP sur l'hébergement OVH pour le domaine  _rifrando.asso.fr_ - à précciser !!!!
    * __cron__ : on récupère les logs des des tâches planifiées qui ont été déclenchées sur l'hébergement OVH pour le domaine  _rifrando.asso.fr_

``` bash
jpmena@jpmena-P34 ~/RIF/Utilitaires/Linux/OVH (master *=) $ ./logOvh.sh rifrando.asso.fr 08-2016 developpeur allezleRIF1976 error
2016/09/02-08:55:23 - La sortie console ssera aussi dans : /home/jpmena/rifrando.asso.fr/error/08-2016/logOvh.sh_20160902_085523.log
2016/09/02-08:55:23 - Création du dossier /home/jpmena/rifrando.asso.fr/error/08-2016
2016/09/02-08:55:23 - Téléchargement des logs...
Authentification sélectionnée : Basic realm="[OVH web stats&logs] - Welcome! please type your logs.ovh.net credentials or your OVH Nic-Handle (lowercase)"
2016-09-02 08:55:23 URL:https://logs.ovh.net/rifrando.asso.fr/logs-08-2016/error/ [6729] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html" [1]
......................................................................
2016-09-02 08:55:30 URL:https://logs.ovh.net/rifrando.asso.fr/?C=N&O=D [9994] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html?C=N&O=D" [1]
2016-09-02 08:55:30 URL:https://logs.ovh.net/rifrando.asso.fr/?C=S&O=A [9994] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html?C=S&O=A" [1]
2016-09-02 08:55:31 URL:https://logs.ovh.net/rifrando.asso.fr/?C=S&O=D [9994] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html?C=S&O=D" [1]
2016-09-02 08:55:31 URL:https://logs.ovh.net/rifrando.asso.fr/?C=M&O=A [9994] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html?C=M&O=A" [1]
2016-09-02 08:55:31 URL:https://logs.ovh.net/rifrando.asso.fr/?C=M&O=D [9994] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html?C=M&O=D" [1]
2016-09-02 08:55:39 URL:https://logs.ovh.net/rifrando.asso.fr/awstats-osl/index.html [425] -> "/home/jpmena/rifrando.asso.fr/error/08-2016/index.html" [1]
Terminé — 2016-09-02 08:55:39 —
Temps total effectif : 17s
Téléchargés : 84 fichiers, 4,1M en 4,0s (1,03 MB/s)
2016/09/02-08:55:39 - terminé vous pouvez récupérer les logs sous : /home/jpmena/rifrando.asso.fr/error/08-2016
```
