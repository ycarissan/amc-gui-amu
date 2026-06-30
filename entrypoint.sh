#!/usr/bin/env bash
# entrypoint.sh — execute en root (PID 1). Prepare l'environnement puis
# lance supervisord en avant-plan. Les services tournent ensuite en tant
# qu'utilisateur "amc" (defini dans amc.conf via user=amc).
set -euo pipefail

# --- Remappage uid/gid pour compatibilite avec les bind mounts hote --------
# Permet d'aligner l'utilisateur du conteneur sur le proprietaire du dossier
# monte (evite les soucis de permissions sur /home/amc).
CUR_UID="$(id -u amc)"
CUR_GID="$(id -g amc)"
if [ "${PGID}" != "${CUR_GID}" ]; then
    groupmod -o -g "${PGID}" amc
fi
if [ "${PUID}" != "${CUR_UID}" ]; then
    usermod -o -u "${PUID}" amc
fi

# --- Parsing de RESOLUTION (ex. 1920x1080x24) ------------------------------
# GEOMETRY = 1920x1080 ; DEPTH = 24. Exportes pour start-vnc.sh.
export GEOMETRY="${RESOLUTION%x*}"
export DEPTH="${RESOLUTION##*x}"

# --- Structure du HOME persistant ------------------------------------------
# .AMC.d : configuration AMC (dont rep_projets) + bases SQLite par projet.
# MC-Projects : repertoire des projets par defaut (doit rester SOUS /home/amc
# pour etre persiste ; si vous le changez dans la GUI, gardez-le ici).
install -d -o amc -g amc -m 0755 /home/amc/MC-Projects /home/amc/.AMC.d
chown amc:amc /home/amc
chown -R amc:amc /home/amc/.AMC.d 2>/dev/null || true
# On NE fait PAS de chown -R sur MC-Projects (potentiellement volumineux) :
# si besoin, l'operateur ajuste les permissions cote hote.

echo "[entrypoint] RESOLUTION=${RESOLUTION} -> GEOMETRY=${GEOMETRY} DEPTH=${DEPTH}"
echo "[entrypoint] utilisateur amc = $(id amc)"

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/amc.conf
