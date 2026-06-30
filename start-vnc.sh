#!/usr/bin/env bash
# start-vnc.sh — serveur X virtuel + VNC en un seul process (Xtigervnc).
# Xtigervnc gere le RANDR / redimensionnement distant (resize=remote cote noVNC).
set -euo pipefail

: "${GEOMETRY:=1920x1080}"
: "${DEPTH:=24}"

# Nettoyage d'eventuels verrous X residuels (redemarrage du conteneur).
rm -f /tmp/.X1-lock 2>/dev/null || true
rm -f /tmp/.X11-unix/X1 2>/dev/null || true

# SecurityTypes None : AUCUN mot de passe VNC (choix assume).
#   => la securite repose ENTIEREMENT sur la publication des ports en
#      127.0.0.1 cote hote (voir docker-compose.yml / README).
# AlwaysShared : autorise noVNC ET un client natif simultanement (session partagee).
# Ecoute sur toutes les interfaces DU CONTENEUR (pas de -localhost) afin que
# le port 5900 publie en loopback hote soit joignable depuis l'hote.
exec Xtigervnc :1 \
    -desktop "AMC" \
    -geometry "${GEOMETRY}" \
    -depth "${DEPTH}" \
    -rfbport 5900 \
    -SecurityTypes None \
    -AlwaysShared \
    -AcceptSetDesktopSize 1
