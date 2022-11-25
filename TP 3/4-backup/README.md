# Module 4 : Sauvegarde du système de fichiers

Dans cette partie, **on va monter un _serveur de sauvegarde_ qui sera chargé d'accueillir les sauvegardes des autres machines**, en particulier du serveur Web qui porte NextCloud.

On fait les mêmes étapes que le module 3 en changeant le script et le nom d'utilisateur: [Reference au module3](../3-db-backup/README.md)

[Script nextcloud backup](./tp3_backup.sh)
[Timer](./backup.timer)
[Timer](./backup.service)

## II. NFS

### 1. Serveur NFS

➜ **Préparer un dossier à partager** sur le réseaucsur la machine `storage.tp3.linux`

```
[audy@storage ~]$ sudo mkdir /srv/nfs_shares
[audy@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp2.linux
[audy@storage ~]$ sudo dnf install nfs-utils
```

➜ **Installer le serveur NFS**

```
[audy@storage ~]$ cat /etc/exports
/srv/nfs_shares    client_ip(rw,sync,no_root_squash,no_subtree_check)

[audy@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[audy@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[audy@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[audy@storage ~]$ sudo firewall-cmd --reload
success
```

### 2. Client NFS

➜ **Installer un client NFS sur `web.tp2.linux`**

```
[audy@web ~]$ sudo dnf install nfs-utils
[...]
[audy@db srv]$ sudo mount -t nfs 10.102.1.15:/srv/nfs_shares/web.tp2.linux/ /srv/backup/
[audy@web ~]$ df -h | grep nfs
10.102.1.15:/srv/nfs_shares/web.tp2.linux  6.2G  1.2G  5.1G  20% /srv/backup
[audy@web ~]$ cat /etc/fstab | grep nfs
10.102.1.15:/srv/nfs_shares/web.tp2.linux/ /srv/backup nfs defaults 0 0
```

➜ **Tester la restauration des données** sinon ça sert à rien :)

```
[audy@web srv]$ sudo ls /srv/backup/
[audy@web srv]$ sudo -u backup bash tp3_backup.sh
[audy@web srv]$ sudo ls /srv/backup/
nextcloud_221122_183521.tar.gz
```

```
[audy@storage ~]$ sudo tree /srv/nfs_shares/
/srv/nfs_shares/
└── web.tp2.linux
    └── nextcloud_221122_183521.tar.gz

2 directories, 2 files
```
