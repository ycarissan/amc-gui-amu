#!/usr/bin/env bash
# start-novnc.sh — pont navigateur (easy-novnc : noVNC + proxy WebSocket integres).
set -euo pipefail
: "${NOVNC_PORT:=6080}"

# Attente que le serveur VNC (Xtigervnc) ecoute sur 5900.
for _ in $(seq 1 60); do
    if (exec 3<>/dev/tcp/127.0.0.1/5900) 2>/dev/null; then
        exec 3>&- || true
        break
    fi
    sleep 0.5
done

# --no-url-password : pas de mot de passe d'URL (coherent avec "MDP aucun").
# resize=remote : exploite le redimensionnement distant de TigerVNC pour
#                 ajuster l'affichage a la fenetre du navigateur.
exec easy-novnc \
    --addr ":${NOVNC_PORT}" \
    --host 127.0.0.1 \
    --port 5900 \
    --no-url-password \
    --novnc-params "resize=remote"
