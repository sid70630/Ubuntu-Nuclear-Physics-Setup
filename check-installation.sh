#!/usr/bin/env bash
set -u

pass=0
missing=0

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf '[OK]      %-20s %s\n' "$name" "$(command -v "$name")"
    pass=$((pass + 1))
  else
    printf '[MISSING] %-20s\n' "$name"
    missing=$((missing + 1))
  fi
}

check_directory() {
  local name="$1"
  local path="$2"
  if [[ -d "$path" ]]; then
    printf '[OK]      %-20s %s\n' "$name" "$path"
    pass=$((pass + 1))
  else
    printf '[MISSING] %-20s %s\n' "$name" "$path"
    missing=$((missing + 1))
  fi
}

[[ -f "$HOME/root/bin/thisroot.sh" ]] && source "$HOME/root/bin/thisroot.sh"
[[ -f "$HOME/GRSISort/thisgrsi.sh" ]] && source "$HOME/GRSISort/thisgrsi.sh"
[[ -f "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" ]] && source "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh"
export PATH="$HOME/GOSIA:$HOME/GREMLIN:$HOME/rw05/src:$PATH"

echo "Commands"
check_command root
check_command root-config
check_command grsisort
check_command gosia
check_command gosia2
check_command gremlin
check_command xmesc
check_command geant4-config

echo
echo "Directories"
check_directory ROOT "$HOME/root"
check_directory GRSISort "$HOME/GRSISort"
check_directory GOSIA "$HOME/GOSIA"
check_directory GREMLIN "$HOME/GREMLIN"
check_directory RadWare "$HOME/rw05"
check_directory Geant4 "$HOME/G4/geant4-v11.4.2-install"
check_directory Nilsson "$HOME/Nilsson"
check_directory "Nuclear chart" "$HOME/nuclear-chart-plotter"
check_directory "Python venv" "$HOME/venvs/nuclear-physics"

echo
echo "Manual/licensed programs"
check_command lise
check_command nushellx
check_command cubix

echo
printf 'Found: %d    Missing: %d\n' "$pass" "$missing"
echo "A missing manual/licensed program is not an installer failure."
