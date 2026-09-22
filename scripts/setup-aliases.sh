#!/bin/bash
# Installe deux raccourcis pratiques dans le shell de l'etudiant.
BRC="$HOME/.bashrc"
grep -q 'R512 aliases' "$BRC" 2>/dev/null && exit 0
cat >> "$BRC" << 'ALIASES'

# R512 aliases
alias start-victim='bash /workspaces/r512-lab/scripts/start-victim.sh'
alias enter-victim='bash /workspaces/r512-lab/scripts/enter-victim.sh'
ALIASES
