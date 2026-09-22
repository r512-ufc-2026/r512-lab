#!/bin/bash
# Installe les raccourcis pratiques dans le shell de l'etudiant.
BRC="$HOME/.bashrc"
grep -q 'R512 aliases' "$BRC" 2>/dev/null && exit 0
cat >> "$BRC" << 'ALIASES'

# R512 aliases
W=/workspaces/r512-lab/scripts
alias start-victim="bash $W/start-victim.sh"
alias enter-victim="bash $W/enter-victim.sh"
alias fetch-windows-logs="bash $W/fetch-windows-logs.sh"
alias win-timeline="bash $W/win-timeline.sh"
alias win-hunt="bash $W/win-hunt.sh"
ALIASES
