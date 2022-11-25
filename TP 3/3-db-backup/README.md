# Module 3 : Sauvegarde de base de données

Dans cette partie le but va être d'écrire un script `bash` qui récupère le contenu de la base de données utilisée par NextCloud, afin d'être en mesure de restaurer les données plus tard si besoin.

Le script utilisera la commande `mysqldump` qui permet de récupérer le contenu de la base de données sous la forme d'un fichier `.sql`.

Ce fichier `.sql` on pourra ensuite le compresser et le placer dans un dossier dédié afin de l'archiver.

Une fois le script fonctionnel, on créera alors un service qui permet de déclencher l'exécution de ce script dans de bonnes conditions.

Enfin, un _timer_ permettra de déclencher l'exécution du _service_ à intervalles réguliers.

## I. Script dump

➜ **Créer un utilisateur DANS LA BASE DE DONNEES**

```
MariaDB [(none)]> CREATE USER 'dump'@'localhost' IDENTIFIED BY 'azerty';
Query OK, 0 rows affected (0.338 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'dump'@'localhost';
Query OK, 0 rows affected (0.001 sec)
```

➜ **Ecrire le script `bash`**

[Script tp3_db_dumps](./tp3_db_dump.sh)

➜ **Environnement d'exécution du script**

```
[audy@db ~]$ cat /etc/passwd | grep db_
db_dumps:x:1001:1001::/srv/db_dumps/:/usr/bin/nologin
[audy@db ~]$ sudo ls -al /srv/db_dumps/
total 144
drwx------. 2 db_dumps db_dumps  4096 Nov 21 14:25 .
drwxr-xr-x. 3 root     root        59 Nov 21 11:00 ..
```

- pour tester l'exécution du script en tant que l'utilisateur `db_dumps`, utilisez la commande suivante :

```bash
[audy@db srv]$ sudo -u db_dumps bash tp3_db_dump.sh
```

---

## III. Service et timer

[Service](./db-dump.service)
[Timer](./db-dump.timer)

```
[audy@db ~]$ sudo systemctl start db-dump
[audy@db ~]$ sudo ls -l /srv/db_dumps/
total 140
-rw-r--r--. 1 db_dumps db_dumps 25431 Nov 21 14:25 db_nextcloud_20221121142537.tar.gz
[audy@db ~]$ sudo systemctl daemon-reload
```

```
[audy@db ~]$ sudo systemctl start db-dump.timer
[audy@db ~]$ sudo systemctl enable db-dump.timer
Created symlink /etc/systemd/system/timers.target.wants/db-dump.timer → /etc/systemd/system/db-dump.timer.
[audy@db ~]$ sudo systemctl status db-dump.timer
● db-dump.timer - Run service db_dump
     Loaded: loaded (/etc/systemd/system/db-dump.timer; enabled; vendor preset: disabled)
     Active: active (waiting) since Mon 2022-11-21 14:27:02 CET; 25s ago
      Until: Mon 2022-11-21 14:27:02 CET; 25s ago
    Trigger: Tue 2022-11-22 04:00:00 CET; 13h left
   Triggers: ● db-dump.service

Nov 21 14:27:02 db.tp2.linux systemd[1]: Started Run service db_dump.

[audy@db ~]$ sudo systemctl list-timers | grep db-dump
Tue 2022-11-22 04:00:00 CET 13h left      n/a                         n/a          db-dump.timer                db-dump.service
```

Test de la restauration

```bash
[audy@db srv]$ sudo systemctl start db-dump
[audy@db srv]$ sudo -u db_dumps ls /srv/db_dumps/
db_nextcloud_221122_181742.tar.gz
[audy@db srv]$ sudo mysql -u root

MariaDB [(none)]> USE nextcloud;
MariaDB [nextcloud]> SELECT FOUND_ROWS();
+--------------+
| FOUND_ROWS() |
+--------------+
|           95 |
+--------------+
1 row in set (0.000 sec)

MariaDB [nextcloud]> DROP TABLE oc_accounts;
Query OK, 0 rows affected (0.052 sec)
MariaDB [nextcloud]> SELECT FOUND_ROWS();
+--------------+
| FOUND_ROWS() |
+--------------+
|           94 |
+--------------+
1 row in set (0.000 sec)

[audy@db srv]$ sudo -u db_dumps tar -xzf db_dumps/db_nextcloud_221122_181742.tar.gz
[audy@db srv]$ sudo -u db_dumps ls /srv/db_dumps/
db_nextcloud_221122_181742.sql  db_nextcloud_221122_181742.tar.gz
[audy@db srv]$ sudo -u db_dumps mysql -u db_dumps -p nextcloud < db_dumps/db_nextcloud_221122_181742.sql
Enter password:
[audy@db srv]$ sudo mysql -u root

MariaDB [(none)]> USE nextcloud;
MariaDB [nextcloud]>  SELECT FOUND_ROWS();
+--------------+
| FOUND_ROWS() |
+--------------+
|           95 |
+--------------+
1 row in set (0.000 sec)
```
