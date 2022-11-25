# Module 7 : Fail2Ban

Fail2Ban c'est un peu le cas d'école de l'admin Linux, je vous laisse Google pour le mettre en place.

C'est must-have sur n'importe quel serveur à peu de choses près. En plus d'enrayer les attaques par bruteforce, il limite aussi l'imact sur les performances de ces attaques, en bloquant complètement le trafic venant des IP considérées comme malveillantes

Faites en sorte que :

```
[audy@db ~]$ sudo systemctl start fail2ban
[audy@db ~]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.
[audy@db ~]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-11-21 15:06:52 CET; 14s ago
```

```
[audy@db ~]$ sudo fail2ban-client status
Status
|- Number of jail:      1
`- Jail list:   sshd
[audy@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.102.1.11


[audy@web ~]$ ssh audy@10.102.1.12
ssh: connect to host 10.102.1.12 port 22: Connection refused
```

```
[audy@db ~]$ sudo fail2ban-client set sshd unbanip 10.102.1.11
1
[audy@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     1
   `- Banned IP list:


[audy@web ~]$ ssh audy@10.102.1.12
audy@10.102.1.12's password:
Last failed login: Mon Nov 21 15:21:42 CET 2022 from 10.102.1.11
```

> Vous pouvez vous faire ban en effectuant une connexion SSH depuis `web.tp2.linux` vers `db.tp2.linux` par exemple, comme ça vous gardez intacte la connexion de votre PC vers `db.tp2.linux`, et vous pouvez continuer à bosser en SSH.
