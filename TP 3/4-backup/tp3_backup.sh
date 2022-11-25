#!/bin/bash
# Ecrit le 22/11/2022 par audy.
# Ce script permet de créer des backups versionnées de fichiers importants nextcloud.


# Variables
file="nextcloud_$(date +"%y%m%d_%H%m%S")"
filepath="backup/${file}"
conf="/var/www/tp2_nextcloud/"

#Création du fichier de backup
/usr/bin/tar -czf "${filepath}.tar.gz" -C "${conf}" config data themes