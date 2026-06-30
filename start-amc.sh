#!/usr/bin/env bash
# start-amc.sh — lancement automatique de la vraie GUI AMC (Perl/Gtk3).
set -euo pipefail
export DISPLAY=:1
export HOME=/home/amc
export LANG=fr_FR.UTF-8 LC_ALL=fr_FR.UTF-8 LANGUAGE=fr_FR:fr
# Evite les avertissements du bridge d'accessibilite at-spi en conteneur.
export NO_AT_BRIDGE=1

# Attente du serveur X.
for _ in $(seq 1 60); do
    [ -S /tmp/.X11-unix/X1 ] && break
    sleep 0.5
done
# Petit delai pour laisser le WM s'initialiser.
sleep 1

# auto-multiple-choice : lanceur officiel de la GUI (appelle AMC-gui.pl).
# Lance dans une session D-Bus dediee (certaines fonctions Gtk3 l'attendent).
exec dbus-launch --exit-with-session auto-multiple-choice
