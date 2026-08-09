#!/usr/bin/env bash

hyprctl reload; 

pkill -9 quickshell
pkill -9 .quickshell-wra
pkill -f qs-watchdog

python3 /home/boing/Dotfiles/scripts/extract_steam_games.py

sleep 0.5
bash /home/boing/Dotfiles/quickshell/scripts/qs-watchdog.sh &
disown