# NOTICE — amc-gui-amu

Cette image Docker empaquette plusieurs logiciels libres distincts. Chaque
composant reste la propriete de ses auteurs respectifs et conserve sa licence.
**Publier cette image ne cede aucune propriete intellectuelle** : chaque auteur
garde son copyright, et les mentions de licence sont conservees dans l'image.

## Logiciel amont empaquete

### Auto Multiple Choice (AMC)
- Role : application principale (gestion de QCM, generation, lecture optique OMR,
  saisie manuelle, association, annotation, notation, envoi d'e-mails).
- Auteur amont : Alexis Bienvenue et contributeurs.
- Licence : **GPL-2.0-or-later**.
- Site : https://www.auto-multiple-choice.net
- Source : https://gitlab.com/a10684/auto-multiple-choice
- Installe depuis les depots Debian (suite *trixie*).

> Les empaqueteurs ci-dessous **ne sont pas** les auteurs d'AMC.

## Composants de la pile d'affichage

| Composant   | Role                                   | Licence (a verifier au build) |
|-------------|----------------------------------------|-------------------------------|
| TigerVNC    | serveur X virtuel + serveur VNC        | GPL-2.0                       |
| easy-novnc  | proxy WebSocket + client noVNC integre | MPL-2.0 (+ composants tiers)  |
| noVNC       | client VNC HTML5 (embarque dans easy-novnc) | MPL-2.0                  |
| fluxbox     | gestionnaire de fenetres               | MIT                           |
| supervisor  | supervision des process                | BSD-like (repackaged)         |
| Debian base + texlive | systeme de base + chaine LaTeX | licences Debian respectives  |

> Les licences exactes des composants doivent etre confirmees a partir des
> paquets reellement installes (`/usr/share/doc/<paquet>/copyright`) au moment du
> build, les versions amont pouvant evoluer.

## Empaquetage (image authors)

Le travail d'**empaquetage** (Dockerfile, scripts d'orchestration, configuration
VNC/noVNC, publication multi-arch) est realise par :

- **Paola Nava** — Aix-Marseille Universite, equipe CTOM (ISM2)
- **Yannick Carissan** — Aix-Marseille Universite, equipe CTOM (ISM2)

Equipe : https://ism2.univ-amu.fr/fr/equipes/ctom/presentation

**Copyright sur l'empaquetage © Paola Nava & Yannick Carissan.** Ce copyright
porte uniquement sur les fichiers d'empaquetage et n'affecte en rien les droits
des auteurs des logiciels amont.

## Compte de publication

Image publiee sur Docker Hub sous le compte `daverc31`
(`daverc31/amc-gui-amu`).
