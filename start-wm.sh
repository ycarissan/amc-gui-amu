#!/usr/bin/env bash
# start-wm.sh — gestionnaire de fenetres leger (fluxbox).
set -euo pipefail
export DISPLAY=:1

# Attente de la disponibilite du serveur X (socket Unix).
for _ in $(seq 1 60); do
    [ -S /tmp/.X11-unix/X1 ] && break
    sleep 0.5
done

exec fluxbox
