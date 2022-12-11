# TP4 : Conteneurs

Dans ce TP on va aborder plusieurs points autour de la conteneurisation :

- Docker et son empreinte sur le système
- Manipulation d'images
- `docker-compose`

# Sommaire

- [TP4 : Conteneurs](#tp4--conteneurs)
- [Sommaire](#sommaire)
- [I. Docker](#i-docker)
  - [1. Install](#1-install)
  - [2. Vérifier l'install](#2-vérifier-linstall)
  - [3. Lancement de conteneurs](#3-lancement-de-conteneurs)
- [II. Images](#ii-images)
- [III. `docker-compose`](#iii-docker-compose)
  - [1. Intro](#1-intro)
  - [2. Make your own meow](#2-make-your-own-meow)

# I. Docker

🖥️ Machine **docker1.tp4.linux**

## 1. Install

🌞 **Installer Docker sur la machine**

```bash
# Install de docker
[audy@docker1 ~]$ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
[audy@docker1 ~]$ sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin

#Start de docker
[audy@docker1 ~]$ sudo systemctl enable docker
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /usr/lib/systemd/system/docker.service.
[audy@docker1 ~]$ sudo systemctl start docker
[audy@docker1 ~]$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-11-24 10:31:07 CET; 4s ago
TriggeredBy: ● docker.socket
```

## 2. Vérifier l'install

➜ **Vérifiez que Docker est actif est disponible en essayant quelques commandes usuelles :**

```bash
# Info sur l'install actuelle de Docker
[audy@docker1 ~]$ docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Docker Buildx (Docker Inc., v0.9.1-docker)
  compose: Docker Compose (Docker Inc., v2.12.2)
  scan: Docker Scan (Docker Inc., v0.21.0)
[...]

# Liste des conteneurs actifs
[audy@docker1 ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
# Liste de tous les conteneurs
[audy@docker1 ~]$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

# Liste des images disponibles localement
[audy@docker1 ~]$ docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```

➜ **Explorer un peu le help**, si c'est pas le man :

```bash
$ docker --help
$ docker run --help
$ man docker
```

## 3. Lancement de conteneurs

🌞 **Utiliser la commande `docker run`**

```bash
[audy@docker1 ~]$ docker run --name web -d -p 7777:777 -m 8000000 -v /home/audy/html:/var/www/tp4 -v /home/audy/nginx:/etc/nginx/conf.d --cpus 1.00 nginx
bc0a2735797aee9218092d18c006670680e73bf7c23771fb69bed8497ee04d74
[audy@docker1 ~]$ curl 172.17.0.2:777
<h1> Hello there </h1>
```

# II. Images

La construction d'image avec Docker est basée sur l'utilisation de fichiers `Dockerfile`.

🌞 **Construire votre propre image**

```bash
[audy@docker1 Docker]$ docker build . -t own_ubuntu2
[...]
[audy@docker1 Docker]$ docker run -d --name test -p 8888:80 own_ubuntu2
5cf51998c450254dc51da4e6612cfdfb38c0057d0814d614729e7f6b1df9c17a
[audy@docker1 Docker]$ curl 172.17.0.2:80
<h1> Hello there </h1>
```

📁 [Dockerfile](./Dockerfile)

# III. `docker-compose`

## 1. Intro

➜ **Installer `docker-compose` sur la machine**

```bash
[audy@docker1 Docker]$ sudo dnf install docker-compose-plugin
```

## 2. Make your own meow

```
[audy@docker1 ~]$ mkdir app && cd app
[leo@docker1 app]$ git clone https://ytrack.learn.ynov.com/git/ACORRE2/hangman-web.git
[audy@docker1 app]$ ls
docker-compose.yml  Dockerfile  hangman-web
[leo@docker1 app]$ docker build . -t testgo
[leo@docker1 app]$ docker compose up
[+] Running 1/0
 ⠿ Container go-hangman-web-1  Created                                                                                                0.1s
Attaching to go-forum-1
go-hangman-web-1  | Listening at http://:8080
[audy@docker1 app]$ curl 172.17.0.2:8080
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="stylesheet" href="./static/home.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
    </style>
    <title>Hangman with José</title>
    <link rel="icon" href="assets/favicon.png" />
</head>
<body onload="Display(false), Easter(false)">
    <h1>Hangman with José</h1>
```

[Dockerfile](./app/Dockerfile)
[Docker-compose.yml](./app/docker-compose.yml)
