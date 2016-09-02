## Ressources :

* I explained in French how to install Drush on 1AND1 [My WIKI In French About Drush and 1AND1](http://wiki.jpmena.eu/index.php?title=Php:drupal8:hebergeurs#1AND1_Mutualis.C3.A9)

* I explained the commaand to be passed to import Randonnée de Journée after the _rif_imports_ module had been installed and activated on [My GitHub rif-imports project](https://github.com/javaskater/rif_imports)

## _drushImpostRj.sh_ the Script's Result :

``` bash
(uiserver):u72756193:~/sites_jpm > ./drushImportRJ.sh
tee: /drushImportRJ.sh_20160902_112239.log: Permission denied
2016/09/02-11:22:39 - I import Randonnees de Jour from /kunden/homepages/21/d462702613/htdocs/sites_jpm/importations/randonnees.csv
X-Powered-By: PHP/5.5.38
Content-type: text/html

2016/09/02-11:23:26 -  - Randonnees de Jour's Import : OK
2016/09/02-11:23:26 - I erase the Randonnees de Jour to be found in /kunden/homepages/21/d462702613/htdocs/sites_jpm/importations/randonnees.eff.csv
X-Powered-By: PHP/5.5.38
Content-type: text/html

<br />
<b>Notice</b>:  Use of undefined constant STDERR - assumed 'STDERR' in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/lib/Drush/Log/Logger.php</b> on line <b>138</b><br />
<br />
<b>Warning</b>:  fwrite() expects parameter 1 to be resource, string given in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/includes/output.inc</b> on line <b>37</b><br />
<br />
<b>Notice</b>:  Use of undefined constant STDERR - assumed 'STDERR' in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/lib/Drush/Log/Logger.php</b> on line <b>138</b><br />
<br />
<b>Warning</b>:  fwrite() expects parameter 1 to be resource, string given in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/includes/output.inc</b> on line <b>37</b><br />
<br />
<b>Notice</b>:  Use of undefined constant STDERR - assumed 'STDERR' in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/lib/Drush/Log/Logger.php</b> on line <b>138</b><br />
<br />
<b>Warning</b>:  fwrite() expects parameter 1 to be resource, string given in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/includes/output.inc</b> on line <b>37</b><br />
<br />
<b>Notice</b>:  Use of undefined constant STDERR - assumed 'STDERR' in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/lib/Drush/Log/Logger.php</b> on line <b>138</b><br />
<br />
<b>Warning</b>:  fwrite() expects parameter 1 to be resource, string given in <b>phar:///homepages/21/d462702613/htdocs/drush.phar/includes/output.inc</b> on line <b>37</b><br />
2016/09/02-11:23:27 -  - Randonnees de Jour's Erasing : OK
```

## Conclusion

* the [Randonnees de Jour on 1AND1](http://prif.jpmena.eu/rif_randos_jour) are present

### problem with creating/writing the Log
### problem with erasing  ...
