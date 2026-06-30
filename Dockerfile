# syntax=docker/dockerfile:1.7
#
# AMC (Auto Multiple Choice) — vraie GUI Perl/Gtk3 exposee dans un navigateur
# via TigerVNC + easy-novnc. Image multi-architecture (linux/amd64, linux/arm64).
#
# Empaqueteurs / image authors : Paola Nava & Yannick Carissan
#   Aix-Marseille Universite, equipe CTOM (ISM2)
#   https://ism2.univ-amu.fr/fr/equipes/ctom/presentation
# Les empaqueteurs NE SONT PAS les auteurs du logiciel amont (AMC, A. Bienvenue).
#
# Licences : AMC = GPL-2.0-or-later ; TigerVNC = GPL-2.0 ; easy-novnc / noVNC = MPL-2.0
# (+ composants tiers). Voir NOTICE.md embarque dans /usr/share/doc/amc-gui-amu/.

############################################################
# Stage 1 — easy-novnc (binaire Go statique, noVNC + proxy WebSocket integres)
############################################################
FROM golang:1.22-bookworm AS easy-novnc-build
WORKDIR /src
ENV CGO_ENABLED=0
# Version epinglee pour la reproductibilite du build (cache deterministe).
# NB : le chemin de module historique est github.com/geek1011/easy-novnc
# (compte renomme depuis en pgaskin ; GitHub redirige).
RUN go install github.com/geek1011/easy-novnc@v1.1.0

############################################################
# Stage 2 — runtime AMC + pile graphique
############################################################
FROM debian:trixie-slim

# ---- Metadonnees OCI (valeurs injectees par publish.sh) -------------------
ARG AMC_VERSION=1.6.0
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="AMC GUI via VNC/noVNC" \
      org.opencontainers.image.description="Auto Multiple Choice (vraie GUI Gtk3) dans un navigateur via TigerVNC + easy-novnc, multi-arch amd64/arm64." \
      org.opencontainers.image.version="${AMC_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.url="https://ism2.univ-amu.fr/fr/equipes/ctom/presentation" \
      org.opencontainers.image.source="https://gitlab.com/a10684/auto-multiple-choice" \
      org.opencontainers.image.authors="Paola Nava, Yannick Carissan (Aix-Marseille Universite, CTOM/ISM2)" \
      org.opencontainers.image.vendor="Aix-Marseille Universite — equipe CTOM (ISM2)"

ENV DEBIAN_FRONTEND=noninteractive

# ---- Paquets : locale FR, AMC, texlive complet, TigerVNC, WM, dbus --------
# texlive-full : compilation LaTeX garantie quelles que soient les sources
# (.sty exotiques, langues, tikz...). Image lourde et build arm64 emule long, assume.
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        locales \
        ca-certificates \
        passwd procps \
        auto-multiple-choice \
        texlive-full \
        ghostscript poppler-utils \
        tigervnc-standalone-server tigervnc-common \
        fluxbox \
        dbus-x11 x11-xserver-utils \
        fonts-dejavu fonts-liberation \
        supervisor \
    ; \
    rm -rf /var/lib/apt/lists/*

# ---- Locale francaise (piege Debian : generer fr_FR.UTF-8 explicitement) --
RUN set -eux; \
    sed -i 's/^# *\(fr_FR.UTF-8 UTF-8\)/\1/' /etc/locale.gen; \
    locale-gen
ENV LANG=fr_FR.UTF-8 \
    LC_ALL=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr

# ---- Utilisateur applicatif non-root (uid/gid remappables au runtime) -----
RUN set -eux; \
    groupadd -g 1000 amc; \
    useradd -m -u 1000 -g 1000 -s /bin/bash amc

# ---- Binaire easy-novnc + scripts + config + attribution ------------------
# Tous les fichiers sont a PLAT dans le contexte de build (aucun sous-dossier).
# --chmod=0755 : lecture + execution pour TOUS (les scripts tournent en tant
# qu'utilisateur "amc", il faut donc rwx pour "other" sur des scripts #!).
COPY --from=easy-novnc-build /go/bin/easy-novnc /usr/local/bin/easy-novnc
COPY --chmod=0755 entrypoint.sh start-vnc.sh start-wm.sh start-amc.sh start-novnc.sh /usr/local/bin/
RUN mkdir -p /etc/supervisor/conf.d /usr/share/doc/amc-gui-amu
COPY amc.conf /etc/supervisor/conf.d/amc.conf
COPY NOTICE.md /usr/share/doc/amc-gui-amu/NOTICE.md
# Robustesse Windows : neutraliser d'eventuelles fins de ligne CRLF dans les
# scripts/config (sans effet sur des fichiers deja en LF Mac/Linux).
RUN sed -i 's/\r$//' \
        /usr/local/bin/entrypoint.sh \
        /usr/local/bin/start-vnc.sh \
        /usr/local/bin/start-wm.sh \
        /usr/local/bin/start-amc.sh \
        /usr/local/bin/start-novnc.sh \
        /etc/supervisor/conf.d/amc.conf

# ---- Reglages par defaut --------------------------------------------------
# RESOLUTION = LARGEURxHAUTEURxPROFONDEUR (parsee par entrypoint.sh)
ENV RESOLUTION=1920x1080x24 \
    PUID=1000 \
    PGID=1000 \
    HOME=/home/amc \
    DISPLAY=:1

# 6080 = noVNC (navigateur) ; 5900 = VNC natif (client lourd type Remmina)
EXPOSE 6080 5900

# HOME applicatif = point de persistance (projets MC-Projects + config ~/.AMC.d)
VOLUME ["/home/amc"]

# supervisord (lance par entrypoint) supervise Xtigervnc, fluxbox, AMC, easy-novnc
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
