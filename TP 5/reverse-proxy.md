# TP5 : Amélioration de la solution

## Choix du reverse proxy

On va utiliser nginx comme reverse proxy.

## Mise en place du reverse proxy

Install nginx rocky 9

```bash
sudo dnf update -y
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo firewall-cmd --add-port=443/tcp --permanent
```

Création du certificat ssl avec clé.

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/tachidesk.key -out /etc/pki/tls/certs/tachidesk.crt
```

On va ensuite créer un fichier de configuration pour notre reverse proxy.

```bash
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name tachidesk.tp5.linux;

    # Port d'écoute de NGINX
    listen 443 ssl;

    ssl_certificate "/etc/pki/tls/certs/tachidesk.crt";
    ssl_certificate_key "/etc/pki/tls/private/tachidesk.key";
    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.104.1.13:4567;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```
