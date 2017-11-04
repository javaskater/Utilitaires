# About the [Drupal 8](https://www.drupal.org/8) local scripts

## Before launching _composerInstallD8WithConf.sh_

* __composerInstallD8WithConf.sh__ is meant to install the latest version of a [Drupal 8](https://www.drupal.org/8) 
  * ready to import the hikes and users from the CSVs files exported from the [RIF](http://rifrando.fr/)'s managing application. 

### [Install locally composer](https://getcomposer.org/download/) on your $HOME directory!!!

* Following that [link for installing locally composer](https://getcomposer.org/download/)
* I pass the following commands from my _$HOME_ directory:

```bash
jpmena@jpmena-P34:~$ php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
jpmena@jpmena-P34:~$ php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
Installer verified
jpmena@jpmena-P34:~$ php composer-setup.php
All settings correct for using Composer
Downloading...

Composer (version 1.5.2) successfully installed to: /home/jpmena/composer.phar
Use it: php composer.phar

jpmena@jpmena-P34:~$ php -r "unlink('composer-setup.php');"
```
