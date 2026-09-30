#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_ARCHIVE="root_v6.32.24.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz"
ROOT_URL="https://root.cern/download/${ROOT_ARCHIVE}"
G4_VERSION="11.4.2"

append_once() {
  local marker="$1"
  local line="$2"
  grep -Fqx "$marker" "$HOME/.bashrc" 2>/dev/null || printf '\n%s\n%s\n' "$marker" "$line" >> "$HOME/.bashrc"
}

clone_if_missing() {
  local url="$1"
  local destination="$2"
  shift 2
  if [[ -d "$destination" ]]; then
    echo "SKIP: $destination already exists"
  else
    git clone "$@" "$url" "$destination"
  fi
}

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "This installer currently supports x86_64 only."
  exit 1
fi

if ! grep -q '^VERSION_ID="24.04"' /etc/os-release; then
  echo "This installer was tested on Ubuntu 24.04 LTS only."
  exit 1
fi

cat <<'EOF'
This installs supported software under your home directory.
Existing installation directories will be skipped, not overwritten.
Geant4 can take a long time to compile and download its data files.
LISE++, NuShellX and CUBIX are not installed by this script.
EOF
read -r -p "Continue? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

sudo apt update
sudo apt install -y \
  binutils cmake dpkg-dev g++ gcc gfortran git make wget \
  libssl-dev libx11-dev libxext-dev libxft-dev libxpm-dev \
  python3 python3-venv python3-pip libtbb-dev libvdt-dev libgif-dev \
  libblas-dev liblapack-dev libreadline-dev libgtk2.0-dev libmotif-dev \
  xfonts-75dpi xfonts-100dpi libxerces-c-dev libglu1-mesa-dev libxmu-dev \
  qt6-base-dev libqt6opengl6-dev

if [[ -d "$HOME/root" ]]; then
  echo "SKIP: $HOME/root already exists"
else
  cd "$HOME"
  wget "$ROOT_URL"
  tar -xzf "$ROOT_ARCHIVE"
fi
source "$HOME/root/bin/thisroot.sh"
append_once "# CERN ROOT 6.32.24" 'source "$HOME/root/bin/thisroot.sh"'

clone_if_missing https://github.com/GRIFFINCollaboration/GRSISort.git "$HOME/GRSISort" --recursive
cd "$HOME/GRSISort"
source ./thisgrsi.sh
make -j"$(nproc)"
append_once "# GRSISort" 'source "$HOME/GRSISort/thisgrsi.sh"'

mkdir -p "$HOME/GOSIA"
cd "$HOME/GOSIA"
[[ -f gosia_20110524.13.f ]] || wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia_20110524.13.f
[[ -f gosia2_20081208.27.f ]] || wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia2_20081208.27.f
gfortran -O2 gosia_20110524.13.f -o gosia
gfortran -O2 gosia2_20081208.27.f -o gosia2
append_once "# GOSIA and GOSIA2" 'export PATH="$HOME/GOSIA:$PATH"'

mkdir -p "$HOME/GREMLIN"
cd "$HOME/GREMLIN"
[[ -f gremlin.f ]] || wget https://www.pas.rochester.edu/~cline/Research/GOSIAcodes/gremlin.f
gfortran -O2 -std=legacy -ffixed-line-length-none gremlin.f -o gremlin
append_once "# GREMLIN" 'export PATH="$HOME/GREMLIN:$PATH"'

clone_if_missing https://github.com/radforddc/rw05.git "$HOME/rw05"
cd "$HOME/rw05/src"
cp Makefile.linux Makefile
make all
make gtk
sed -i 's/[[:space:]]-lXp//g' Makefile
make xm
append_once "# RadWare" 'export RADWARE_FONT_LOC="$HOME/rw05/font"; export RADWARE_ICC_LOC="$HOME/rw05/icc"; export RADWARE_GFONLINE_LOC="$HOME/rw05/doc"; export RADWARE_CURSOR_BELL=n; export RADWARE_OVERWRITE_FILE=ask; export RADWARE_AWAIT_RETURN=n; export RADWARE_XMG_SIZE=600x500; export PATH="$PATH:$HOME/rw05/src"'

if [[ ! -d "$HOME/venvs/nuclear-physics" ]]; then
  python3 -m venv "$HOME/venvs/nuclear-physics"
fi
source "$HOME/venvs/nuclear-physics/bin/activate"
python -m pip install --upgrade pip
python -m pip install numpy scipy matplotlib pandas jupyterlab uproot awkward iminuit
deactivate

clone_if_missing https://github.com/wimmer-k/Nilsson.git "$HOME/Nilsson"
if [[ ! -d "$HOME/venvs/nilsson" ]]; then
  python3 -m venv "$HOME/venvs/nilsson"
fi
source "$HOME/venvs/nilsson/bin/activate"
python -m pip install --upgrade pip
python -m pip install numpy matplotlib
deactivate

clone_if_missing https://github.com/jonas-ka/nuclear-chart-plotter.git "$HOME/nuclear-chart-plotter"

mkdir -p "$HOME/G4"
cd "$HOME/G4"
if [[ ! -d "geant4-v${G4_VERSION}" ]]; then
  wget "https://gitlab.cern.ch/geant4/geant4/-/archive/v${G4_VERSION}/geant4-v${G4_VERSION}.tar.gz"
  tar -xzf "geant4-v${G4_VERSION}.tar.gz"
fi
cmake -S "$HOME/G4/geant4-v${G4_VERSION}" -B "$HOME/G4/geant4-v${G4_VERSION}-build" \
  -DCMAKE_INSTALL_PREFIX="$HOME/G4/geant4-v${G4_VERSION}-install" \
  -DCMAKE_BUILD_TYPE=Release \
  -DGEANT4_BUILD_MULTITHREADED=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_GDML=ON
cmake --build "$HOME/G4/geant4-v${G4_VERSION}-build" --parallel 4
cmake --install "$HOME/G4/geant4-v${G4_VERSION}-build"
append_once "# Geant4 11.4.2" 'source "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh"'

echo
echo "Installation complete. Open a new terminal, then run:"
echo "  bash check-installation.sh"
echo
echo "Manual installations: CUBIX, LISE++ and NuShellX. See README.md."
