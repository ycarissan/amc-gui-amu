# amc-gui-amu

**Auto Multiple Choice (AMC)** — la *vraie* interface graphique Perl/Gtk3 —
accessible **dans votre navigateur** via TigerVNC + easy-novnc.
Image **multi-architecture** (`linux/amd64` + `linux/arm64`), base **Debian trixie**,
locale **fr_FR.UTF-8**, chaine **LaTeX complete** (`texlive-full`).

Parite fonctionnelle avec la GUI de bureau : redaction, generation, lecture
optique automatique (OMR), **saisie manuelle des cases ambigues**, association,
annotation, notation, envoi d'e-mails.

> Usage **mono-utilisateur / mono-session**. Empaquetage par Paola Nava &
> Yannick Carissan (Aix-Marseille Universite, equipe CTOM/ISM2). AMC est un
> logiciel libre tiers (GPL-2.0-or-later) ; les empaqueteurs n'en sont pas les
> auteurs. Voir `NOTICE.md` dans `/usr/share/doc/amc-gui-amu/`.

---

## Demarrage rapide

### Avec docker compose (recommande)

```yaml
services:
  amc:
    image: daverc31/amc-gui-amu:latest
    container_name: amc-gui-amu
    environment:
      RESOLUTION: "1920x1080x24"
      PUID: "1000"
      PGID: "1000"
    ports:
      - "127.0.0.1:6080:6080"   # noVNC (navigateur)
      - "127.0.0.1:5900:5900"   # VNC natif (client lourd)
    volumes:
      - ./amc-data:/home/amc
    shm_size: "512m"
    restart: unless-stopped
```

```bash
docker compose up -d
```

Puis ouvrez **http://localhost:6080/** et cliquez sur *Connect*.

### En une commande (sans compose)

**Linux / macOS :**
```bash
mkdir -p amc-data
docker run -d --name amc-gui-amu \
  -p 127.0.0.1:6080:6080 \
  -p 127.0.0.1:5900:5900 \
  -e RESOLUTION=1920x1080x24 \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$(pwd)/amc-data:/home/amc" \
  --shm-size=512m \
  daverc31/amc-gui-amu:latest
```

**Windows (PowerShell) :**
```powershell
mkdir amc-data
docker run -d --name amc-gui-amu `
  -p 127.0.0.1:6080:6080 `
  -p 127.0.0.1:5900:5900 `
  -e RESOLUTION=1920x1080x24 `
  -v ${PWD}\amc-data:/home/amc `
  --shm-size=512m `
  daverc31/amc-gui-amu:latest
```
> Sous Windows, `PUID`/`PGID` n'ont pas d'effet utile (geres par Docker Desktop) ;
> on les omet.

---

## Acces

| Mode             | Adresse                  | Remarque                                  |
|------------------|--------------------------|-------------------------------------------|
| Navigateur (noVNC) | http://localhost:6080/ | aucun client a installer                  |
| Client VNC natif | `localhost:5900`         | Remmina, TigerVNC Viewer, Royal TSX, etc. |

Les deux acces peuvent etre utilises **simultanement** (session partagee).
L'affichage se **redimensionne** automatiquement a la fenetre du navigateur.

---

## Persistance des donnees

Tout le HOME applicatif est monte en volume sur `/home/amc` :

- `MC-Projects/` — repertoire **des projets** AMC ;
- `.AMC.d/` — **configuration** AMC (dont le chemin des projets `rep_projets`)
  et bases SQLite par projet.

> **Important** (piege connu) : deplacer la configuration ne deplace pas
> forcement le repertoire des projets — ce sont deux reglages distincts dans
> AMC. Si vous changez le repertoire des projets depuis la GUI, **conservez-le
> sous `/home/amc`** (p. ex. `/home/amc/MC-Projects`) pour qu'il soit persiste.
> Sauvegarde/transfert = copier le dossier `amc-data/`.

---

## Securite

- Les ports sont publies **uniquement sur `127.0.0.1`** dans les exemples
  ci-dessus. Le serveur VNC est **sans mot de passe** (choix de configuration) :
  la securite repose entierement sur ce binding loopback.
- **Ne jamais** publier `6080`/`5900` sur `0.0.0.0` ou une IP de reseau non
  maitrise. Pour un acces distant, passez par un tunnel SSH :
  ```bash
  ssh -L 6080:127.0.0.1:6080 utilisateur@hote-docker
  ```
  puis ouvrez http://localhost:6080/ en local.
- Pour un usage LAN maitrise, ajoutez vous-meme une couche d'authentification
  (reverse-proxy + TLS + mot de passe) en amont.

---

## Variables d'environnement

| Variable     | Defaut          | Role                                            |
|--------------|-----------------|-------------------------------------------------|
| `RESOLUTION` | `1920x1080x24`  | resolution de l'affichage virtuel (LxHxprof.)   |
| `PUID`       | `1000`          | UID de l'utilisateur applicatif (bind mounts)   |
| `PGID`       | `1000`          | GID de l'utilisateur applicatif (bind mounts)   |
| `NOVNC_PORT` | `6080`          | port interne du pont navigateur                 |

---

## Limites connues

- **Scanner physique** non accessible depuis le conteneur : numerisez a
  l'exterieur, puis deposez les fichiers (PDF/images) dans `amc-data/`.
- **Impression** : la voie la plus portable est *imprimer vers PDF* dans AMC,
  puis imprimer le PDF depuis l'hote.
- Mono-session : une seule session graphique partagee a la fois.

---

## Depannage

| Symptome                                  | Piste                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------|
| Page noVNC vide / "Failed to connect"     | attendre quelques secondes (demarrage X+AMC) ; `docker logs amc-gui-amu` |
| Permissions sur `amc-data/`               | aligner `PUID`/`PGID` sur `id -u`/`id -g` cote hote                    |
| Affichage trop petit/grand                | ajuster `RESOLUTION` puis `docker compose up -d` (recreate)           |
| GUI gelee / fermee                        | supervisord relance AMC automatiquement ; sinon `docker restart`      |

Logs detailles :
```bash
docker logs -f amc-gui-amu
```

---

## Tags

- `latest` — derniere version publiee
- `1.6.0` — version AMC
- `1.6.0-trixie` — version AMC + suite Debian

## Licences & credits

AMC : GPL-2.0-or-later · TigerVNC : GPL-2.0 · easy-novnc/noVNC : MPL-2.0 ·
fluxbox : MIT. Empaquetage © Paola Nava & Yannick Carissan (AMU, CTOM/ISM2).
Details : `NOTICE.md` embarque dans l'image.
