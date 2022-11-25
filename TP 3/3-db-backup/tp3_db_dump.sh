#!/bin/bash
#Ecrit le 21/11/22 par audy.
#Ce script permet de créer des backups versionnées d'une base de données avec mysqldump.

#Variables
user="dump"
source /srv/db_pass
date=$(date +%y%m%d%H%M%S)
basename="nextcloud"
name=("db_${basename}_${date}")
filepath=db_dumps/"$name"

#Création du fichier de backup
/usr/bin/mysqldumpmysqldump -u ${user} -p${password} ${basename} > ${filepath}.sql
/usr/bin/tar zcf  "${filepath}.tar.gz" --remove-files "${filepath}.sql"