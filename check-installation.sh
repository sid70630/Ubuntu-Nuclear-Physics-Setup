#!/usr/bin/env bash

pass=0
missing=0

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf '[OK]      %-22s %s\n' "$name" "$(command -v "$name")"
    pass=$((pass + 1))
  else
    printf '[MISSING] %-22s\n' "$name"
    missing=$((missing + 1))
  fi
}

check_directory() {
  local name="$1"
  local path="$2"
  if [[ -d "$path" ]]; then
    printf '[OK]      %-22s %s\n' "$name" "$path"
    pass=$((pass + 1))
  else
    printf '[MISSING] %-22s %s\n' "$name" "$path"
    missing=$((missing + 1))
  fi
}

[[ -f "$HOME/root/bin/thisroot.sh" ]] && source "$HOME/root/bin/thisroot.sh" >/dev/null
[[ -f "$HOME/GRSISort/thisgrsi.sh" ]] && source "$HOME/GRSISort/thisgrsi.sh" >/dev/null
[[ -f "$HOME/Cubix/cubix-install/bin/thiscubix.sh" ]] && source "$HOME/Cubix/cubix-install/bin/thiscubix.sh" >/dev/null
[[ -f "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" ]] && source "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" >/dev/null
export PATH="$HOME/.local/bin:$HOME/GOSIA:$HOME/GREMLIN:$HOME/rw05/src:$PATH"

echo "Commands"
check_command root
check_command root-config
check_command grsisort
check_command gosia
check_command gosia2
check_command gremlin
check_command xmesc
check_command cubix
check_command cubix-config
check_command tkn-config
check_command geant4-config
check_command lise++

echo
echo "Directories"
check_directory ROOT "$HOME/root"
check_directory GRSISort "$HOME/GRSISort"
check_directory GOSIA "$HOME/GOSIA"
check_directory GREMLIN "$HOME/GREMLIN"
check_directory RadWare "$HOME/rw05"
check_directory "Python environment" "$HOME/venvs/nuclear-physics"
check_directory Nilsson "$HOME/Nilsson"
check_directory "Nilsson environment" "$HOME/venvs/nilsson"
check_directory "Nuclear Chart Plotter" "$HOME/NuclearChart/nuclear-chart-plotter"
check_directory "Nuclear chart environment" "$HOME/NuclearChart/nuclear-chart-env"
check_directory CUBIX "$HOME/Cubix/cubix-install"
check_directory Geant4 "$HOME/G4/geant4-v11.4.2-install"

echo
printf 'Found: %d    Missing: %d\n' "$pass" "$missing"

if (( missing > 0 )); then
  echo "See the matching section in README.md."
  exit 1
fi

echo "All checked commands and directories were found."
