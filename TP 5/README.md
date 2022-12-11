# TP5 : Hébergement d'une solution libre et opensource

## Choix de la solution

La solution choisie a été l'application tachidesk qui permet de lire des mangas en ligne.

## Mise en place de la solution

La solution a été mise en place sur un serveur dédié à l'application tachidesk avec docker.

Veillez à installer docker sur votre serveur.

Install docker rocky 9

```bash
sudo dnf update -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
```

Install tachidesk

```bash
docker pull ghcr.io/suwayomi/tachidesk
```

On va ensuite créer un service pour lancer l'application au démarrage du serveur.

Pour que le server soit accessible on va ouvrir le port 4567.

```bash
sudo firewall-cmd --add-port=4567/tcp --permanent
```

```bash
sudo nano /etc/systemd/system/tachidesk.service
sudo systemctl daemon-reload
sudo systemctl enable tachidesk.service
sudo systemctl start tachidesk.service
```

[tachidesk.service](tachidesk.service)

On peut maintenat accéder à l'application sur le port 4567 en utilisant l'adresse ip du serveur dans notre navigateur.

## Amélioration de la solution

Pour améliorer la solution on va utiliser un reverse proxy pour pouvoir accéder à l'application via un nom de domaine et ainsi utiliser un protocole sécurisé.

[Reverse proxy](reverse-proxy.md)
