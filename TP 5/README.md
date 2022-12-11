# TP5 : Hébergement d'une solution libre et opensource

Le but de ce TP est de remettre en oeuvre les compétences acquises au fil de l'année.

On va donc s'exercer autour de l'hébergement d'une solution que vous aurez choisi.

Seule contrainte pour le choix de la solution : elle doit être libre et opensource.

Votre tâche consiste à :

- choisir une solution libre et opensource
- mettre en place la solution
  - installation, configuration, lancement
  - accéder à la solution : tester qu'elle fonctionne
- amélioration de la solution
  - sécurité & robustesse
  - respect des bonnes pratiques

> Ce TP s'apparente donc beaucoup aux TP2 et TP3 que nous avons réalisé ensemble (install de NextCloud + amélioration de la solution).

Le TP s'effectue à 2 ou seul.

## Sommaire

- [TP5 : Hébergement d'une solution libre et opensource](#tp5--hébergement-dune-solution-libre-et-opensource)
  - [Sommaire](#sommaire)
  - [Déroulement](#déroulement)
    - [Choix de la solution](#choix-de-la-solution)
    - [Mise en place de la solution](#mise-en-place-de-la-solution)
    - [Maîtrise de la solution](#maîtrise-de-la-solution)
    - [Amélioration de la solution](#amélioration-de-la-solution)
  - [Rendu attendu](#rendu-attendu)

## Déroulement

### Choix de la solution

La solution choisie a été l'application tachidesk qui permet de lire des mangas en ligne.

### Mise en place de la solution

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