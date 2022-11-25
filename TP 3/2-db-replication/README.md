# Module 2 : Réplication de base de données

```
CREATE USER 'replication_user'@'10.102.1.14' IDENTIFIED BY *****;
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'10.102.1.14';
```

```
[audy@db ~]$ sudo mariabackup --backup    --target-dir=/backup/    --user=root --password=*****

[audy@db2 ~]$ scp -r root@10.102.1.12:/backup/* /backup/

[audy@db2 ~]$ mariabackup --prepare --target-dir=/backup/

[audy@db2 ~]$ mariabackup --copy-back --target-dir=/backup/
```

```
MariaDB [(none)]> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 10.102.1.12
                   Master_User: replication_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000004
           Read_Master_Log_Pos: 389
                Relay_Log_File: mariadb-relay-bin.000002
                 Relay_Log_Pos: 557
         Relay_Master_Log_File: master1-bin.000004
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
```

Côté db originale

```
MariaDB [(none)]> CREATE DATABASE test2;
Query OK, 1 row affected (0.000 sec)
```

Côté backup

```
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
| test2              |
+--------------------+
```

✨ **Bonus** : Faire en sorte que l'utilisateur créé en base de données ne soit utilisable que depuis l'autre serveur de base de données

Commande utilisée plus haut

```
CREATE USER 'replication_user'@'10.102.1.14' IDENTIFIED BY *****;
```

✨ **Bonus** : Mettre en place un setup _master-master_ où les deux serveurs sont répliqués en temps réel, mais les deux sont capables de traiter les requêtes.
