# TP2 : Gestion de service

Dans ce TP on va s'orienter sur l'**utilisation des systèmes GNU/Linux** comme un outil pour **faire tourner des services**. C'est le principal travail de l'administrateur système : fournir des services.

Ces services, on fait toujours la même chose avec :

- **installation** (opération ponctuelle)
- **configuration** (opération ponctuelle)
- **maintien en condition opérationnelle** (opération continue, tant que le service est actif)
- **renforcement niveau sécurité** (opération ponctuelle et continue : on conf robuste et on se tient à jour)

**Dans cette première partie, on va voir la partie installation et configuration.** Peu importe l'outil visé, de la base de données au serveur cache, en passant par le serveur web, le serveur mail, le serveur DNS, ou le serveur privé de ton meilleur jeu en ligne, c'est toujours pareil : install into conf.

On abordera la sécurité et le maintien en condition opérationelle dans une deuxième partie.

**On va apprendre à maîtriser un peu ces étapes, et pas simplement suivre la doc.**

On va maîtriser le service fourni :

- manipulation du service avec systemd
- quelle IP et quel port il utilise
- quels utilisateurs du système sont mobilisés
- quels processus sont actifs sur la machine pour que le service soit actif
- gestion des fichiers qui concernent le service et des permissions associées
- gestion avancée de la configuration du service

---

Bon le service qu'on va setup c'est NextCloud. **JE SAIS** ça fait redite avec l'an dernier, me tapez pas. ME TAPEZ PAS.

Mais vous inquiétez pas, on va pousser le truc, on va faire évoluer l'install, l'architecture de la solution. Cette première partie de TP, on réalise une install basique, simple, simple, basique, la version _vanilla_ un peu. Ce que vous êtes censés commencer à maîtriser (un peu, faites moi plais).

Refaire une install guidée, ça permet de s'exercer à faire ça proprement dans un cadre, bien comprendre, et ça me fait un pont pour les B1C aussi :)

On va faire évoluer la solution dans la suite de ce TP.

# Sommaire

- [TP2 : Gestion de service](#tp2--gestion-de-service)
- [Sommaire](#sommaire)
- [0. Prérequis](#0-prérequis)
  - [Checklist](#checklist)
- [I. Un premier serveur web](#i-un-premier-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)
- [II. Une stack web plus avancée](#ii-une-stack-web-plus-avancée)
  - [1. Intro blabla](#1-intro-blabla)
  - [2. Setup](#2-setup)
    - [A. Base de données](#a-base-de-données)
    - [B. Serveur Web et NextCloud](#b-serveur-web-et-nextcloud)
    - [C. Finaliser l'installation de NextCloud](#c-finaliser-linstallation-de-nextcloud)

# 0. Prérequis

➜ Machines Rocky Linux

➜ Un unique host-only côté VBox, ça suffira. **L'adresse du réseau host-only sera `10.102.1.0/24`.**

➜ Chaque **création de machines** sera indiquée par **l'emoji 🖥️ suivi du nom de la machine**

➜ Si je veux **un fichier dans le rendu**, il y aura l'**emoji 📁 avec le nom du fichier voulu**. Le fichier devra être livré tel quel dans le dépôt git, ou dans le corps du rendu Markdown si c'est lisible et correctement formaté.

## Checklist

A chaque machine déployée, vous **DEVREZ** vérifier la 📝**checklist**📝 :

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel avec un échange de clé
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux désactivé (vérifiez avec `sestatus`, voir

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

# I. Un premier serveur web

## 1. Installation

🖥️ **VM web.tp2.linux**

| Machine         | IP            | Service     |
| --------------- | ------------- | ----------- |
| `web.tp2.linux` | `10.102.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

```
[audy@web ~]$ sudo dnf install httpd
[audy@web ~]$ vim /etc/httpd/conf/httpd.conf
```

- la conf se trouve dans `/etc/httpd/`
  - le fichier de conf principal est `/etc/httpd/conf/httpd.conf`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`

🌞 **Démarrer le service Apache**

```
[audy@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[audy@web ~]$ sudo systemctl start httpd
[audy@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent

[audy@web ~]$ sudo ss -alnpt
State       Recv-Q      Send-Q           Local Address:Port           Peer Address:Port      Process
LISTEN      0           128                    0.0.0.0:22                  0.0.0.0:*          users:(("sshd",pid=732,fd=3))
LISTEN      0           511                          *:80                        *:*          users:(("httpd",pid=5216,fd=4),("httpd",pid=5215,fd=4),("httpd",pid=5214,fd=4),("httpd",pid=497
```

🌞 **TEST**

```
[audy@web ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-15 14:32:04 CET; 7min ago
[...]
```

```
[audy@web ~]$ curl localhost
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
[...]
```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[audy@web ~]$ cat /usr/lib/systemd/system/httpd.service
[...]
[Service]
Type=notify
Environment=LANG=C
[...]
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[audy@web ~]$ cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache
```

```
[audy@web ~]$ ps -ef | grep http
root        4979       1  0 14:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5213    4979  0 14:35 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5214    4979  0 14:35 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5215    4979  0 14:35 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      5216    4979  0 14:35 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
audy        5468    4317  0 14:50 pts/0    00:00:00 grep --color=auto http
```

```
[audy@web ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Nov 15 14:25 .
drwxr-xr-x. 81 root root 4096 Nov 15 14:27 ..
-rw-r--r--.  1 root root 7620 Jul  6 04:37 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```
[audy@web ~]$ sudo useradd cristiano -m -s /sbin/nologin -u 2000
```

```
[audy@web ~]$ cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User cristiano
Group cristiano
[...]
```

```
[audy@web ~]$ systemctl restart httpd

[audy@web ~]$ ps -ef | grep httpd
root        5500       1  0 14:58 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
cristia+    5501    5500  0 14:58 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
cristia+    5502    5500  0 14:58 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
cristia+    5503    5500  0 14:58 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
cristia+    5504    5500  0 14:58 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
audy        5719    4317  0 14:58 pts/0    00:00:00 grep --color=auto httpd
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[audy@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 888
[audy@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[audy@web ~]$ sudo firewall-cmd --add-port=888/tcp --permanent
success
[audy@web ~]$ sudo systemctl restart httpd
```

```
[audy@web ~]$ ss -alnpt
State                 Recv-Q                Send-Q                                Local Address:Port                                 Peer Address:Port                Process
LISTEN                0                     128                                         0.0.0.0:22                                        0.0.0.0:*
LISTEN                0                     128                                            [::]:22                                           [::]:*
LISTEN                0                     511                                               *:888                                             *:*
```

```
[audy@web ~]$ curl localhost:888
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
[...]
```

📁[Fichier de conf](httpd.conf)

# II. Une stack web plus avancée

⚠⚠⚠ **Réinitialiser votre conf Apache avant de continuer** ⚠⚠⚠  
En particulier :

- reprendre le port par défaut
- reprendre l'utilisateur par défaut

## 1. Intro blabla

| Machines        | IP            | Service                 |
| --------------- | ------------- | ----------------------- |
| `web.tp2.linux` | `10.102.1.11` | Serveur Web             |
| `db.tp2.linux`  | `10.102.1.12` | Serveur Base de Données |

## 2. Setup

### A. Base de données

🌞 **Install de MariaDB sur `db.tp2.linux`**

```
[audy@db ~]$ sudo dnf install mariadb-server
[...]

[audy@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

[audy@db ~]$ sudo systemctl start mariadb

[audy@db ~]$ sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] Y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

```
[audy@db ~]$ ss -alntp
State                 Recv-Q                Send-Q                                Local Address:Port                                 Peer Address:Port                Process
LISTEN                0                     128                                         0.0.0.0:22                                        0.0.0.0:*
LISTEN                0                     80                                                *:3306                                            *:*
LISTEN                0                     128                                            [::]:22                                           [::]:*

[audy@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[audy@db ~]$ sudo firewall-cmd --reload
success
```

🌞 **Préparation de la base pour NextCloud**

```
[audy@db ~]$ sudo mysql -u root -p
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 11
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.102.1.11' IDENTIFIED BY 'azerty';
Query OK, 0 rows affected (0.019 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.102.1.11';
Query OK, 0 rows affected (0.015 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```

🌞 **Exploration de la base de données**

```
[audy@web ~]$ mysql -u nextcloud -h 10.102.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

- **donc vous devez effectuer une commande `mysql` sur `web.tp2.linux`**
- une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base

```sql
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)
mysql> USE information_schema;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SHOW TABLES;
+---------------------------------------+
| Tables_in_information_schema          |
+---------------------------------------+
| ALL_PLUGINS                           |
| APPLICABLE_ROLES                      |
| CHARACTER_SETS                        |
[...]
82 rows in set (0.00 sec)
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
[audy@db ~]$ sudo mysql -u root
[sudo] password for audy:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 13
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SELECT user FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.001 sec)
```

> Les utilisateurs de la base de données sont différents des utilisateurs du système Rocky Linux qui porte la base. Les utilisateurs de la base définissent des identifiants utilisés pour se connecter à la base afin d'y voir ou d'y modifier des données.

Une fois qu'on s'est assurés qu'on peut se co au service de base de données depuis `web.tp2.linux`, on peut continuer.

### B. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

🌞 **Install de PHP**

```bash
[audy@web ~]$ sudo dnf config-manager --set-enabled crb

[audy@web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[...]
Complete!

[audy@web ~]$ dnf module list php
[...]

[audy@web ~]$ sudo dnf module enable php:remi-8.1 -y
[...]

[audy@web ~]$ sudo dnf install -y php81-php
[...]
Complete!
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```bash
[audy@web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
[...]
Complete!
```

🌞 **Récupérer NextCloud**

- créez le dossier `/var/www/tp2_nextcloud/`

```
[audy@web ~]$ sudo mkdir /var/www/tp2_nextcloud/
```

```
[audy@web ~]$ wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
[audy@web ~]$ unzip nextcloud-25.0.0rc3.zip
[audy@web ~]$ sudo cp -r nextcloud/* /var/www/tp2_nextcloud/

[audy@web ~]$ ls -al /var/www/tp2_nextcloud/
total 132
drwxr-xr-x. 14 apache apache  4096 Nov 15 16:05 .
drwxr-xr-x.  5 root   root      54 Nov 15 15:54 ..
drwxr-xr-x. 47 apache apache  4096 Nov 15 16:05 3rdparty
drwxr-xr-x. 50 apache apache  4096 Nov 15 16:05 apps
-rw-r--r--.  1 apache apache 19327 Nov 15 16:05 AUTHORS
drwxr-xr-x.  2 apache apache    67 Nov 15 16:05 config
-rw-r--r--.  1 apache apache  4095 Nov 15 16:05 console.php
-rw-r--r--.  1 apache apache 34520 Nov 15 16:05 COPYING
drwxr-xr-x. 23 apache apache  4096 Nov 15 16:05 core
-rw-r--r--.  1 apache apache  6317 Nov 15 16:05 cron.php
drwxr-xr-x.  2 apache apache  8192 Nov 15 16:05 dist
-rw-r--r--.  1 apache apache   156 Nov 15 16:05 index.html
-rw-r--r--.  1 apache apache  3456 Nov 15 16:05 index.php
drwxr-xr-x.  6 apache apache   125 Nov 15 16:05 lib
-rw-r--r--.  1 apache apache   283 Nov 15 16:05 occ
drwxr-xr-x.  2 apache apache    23 Nov 15 16:05 ocm-provider
drwxr-xr-x.  2 apache apache    55 Nov 15 16:05 ocs
drwxr-xr-x.  2 apache apache    23 Nov 15 16:05 ocs-provider
-rw-r--r--.  1 apache apache  3139 Nov 15 16:05 public.php
-rw-r--r--.  1 apache apache  5426 Nov 15 16:05 remote.php
drwxr-xr-x.  4 apache apache   133 Nov 15 16:05 resources
-rw-r--r--.  1 apache apache    26 Nov 15 16:05 robots.txt
-rw-r--r--.  1 apache apache  2452 Nov 15 16:05 status.php
drwxr-xr-x.  3 apache apache    35 Nov 15 16:05 themes
drwxr-xr-x.  2 apache apache    43 Nov 15 16:05 updater
-rw-r--r--.  1 apache apache   387 Nov 15 16:05 version.php
```

🌞 **Adapter la configuration d'Apache**

```
[audy@web ~]$ sudo nano /etc/httpd/conf.d/nextcloud.conf
```

```apache
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp2_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp2.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp2_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```
[audy@web ~]$ sudo systemctl restart httpd
```

### C. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

```
[audy@db ~]$ sudo mysql -u root
[sudo] password for audy:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 61
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
+--------------------+
4 rows in set (0.000 sec)

MariaDB [(none)]> USE nextcloud;
Database changed
MariaDB [nextcloud]> SELECT FOUND_ROWS();
+--------------+
| FOUND_ROWS() |
+--------------+
|           95 |
+--------------+
1 row in set (0.000 sec)
```
