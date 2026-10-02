#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_VERSION="6.32.24"
ROOT_ARCHIVE="root_v${ROOT_VERSION}.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz"
G4_VERSION="11.4.2"
CUBIX_VERSION="v1.5"
JOBS="${JOBS:-4}"

add_block() {
  local marker="$1"
  local block="$2"
  grep -Fq "$marker" "$HOME/.bashrc" 2>/dev/null || printf '\n%s\n' "$block" >> "$HOME/.bashrc"
}

clone_if_missing() {
  local url="$1"
  local destination="$2"
  shift 2
  if [[ -d "$destination/.git" ]]; then
    echo "SKIP: $destination already exists"
  elif [[ -e "$destination" ]]; then
    echo "ERROR: $destination exists but is not a Git repository"
    exit 1
  else
    git clone "$@" "$url" "$destination"
  fi
}

[[ "$(uname -m)" == "x86_64" ]] || { echo "This installer supports x86_64 only."; exit 1; }
grep -q '^VERSION_ID="24.04"' /etc/os-release || { echo "This installer was tested on Ubuntu 24.04 LTS only."; exit 1; }

cat <<'EOF'
This installs all codes under home directory.
Existing Git repositories will be kept.
EOF
read -r -p "Lets Goooo? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

sudo apt update
sudo apt install -y \
  binutils cmake dpkg-dev g++ gcc gfortran git make wget \
  libssl-dev libx11-dev libxext-dev libxft-dev libxpm-dev \
  python3 python3-venv python3-pip libtbb-dev libvdt-dev libgif-dev \
  libblas-dev liblapack-dev libreadline-dev libgtk2.0-dev libmotif-dev \
  xfonts-75dpi xfonts-100dpi libxerces-c-dev libglu1-mesa-dev libxmu-dev \
  qt6-base-dev libqt6opengl6-dev

# ROOT
if [[ ! -f "$HOME/root/bin/thisroot.sh" ]]; then
  cd "$HOME"
  [[ -f "$ROOT_ARCHIVE" ]] || wget "https://root.cern/download/$ROOT_ARCHIVE"
  tar -xzf "$ROOT_ARCHIVE"
fi
source "$HOME/root/bin/thisroot.sh" >/dev/null
add_block "# CERN ROOT $ROOT_VERSION" '# CERN ROOT 6.32.24
if [ -f "$HOME/root/bin/thisroot.sh" ]; then
    source "$HOME/root/bin/thisroot.sh" >/dev/null
fi'

# GRSISort
clone_if_missing https://github.com/GRIFFINCollaboration/GRSISort.git "$HOME/GRSISort" --recursive
git -C "$HOME/GRSISort" submodule update --init --recursive
cd "$HOME/GRSISort"
source ./thisgrsi.sh >/dev/null
make -j"$JOBS"
add_block "# GRSISort" '# GRSISort
if [ -f "$HOME/GRSISort/thisgrsi.sh" ]; then
    source "$HOME/GRSISort/thisgrsi.sh" >/dev/null
fi'

# GOSIA and GOSIA2
mkdir -p "$HOME/GOSIA"
cd "$HOME/GOSIA"
[[ -f gosia_20110524.13.f ]] || wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia_20110524.13.f
[[ -f gosia2_20081208.27.f ]] || wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia2_20081208.27.f
gfortran -O2 gosia_20110524.13.f -o gosia
gfortran -O2 gosia2_20081208.27.f -o gosia2
add_block "# GOSIA and GOSIA2" '# GOSIA and GOSIA2
export PATH="$HOME/GOSIA:$PATH"'

# GREMLIN
mkdir -p "$HOME/GREMLIN"
cd "$HOME/GREMLIN"
[[ -f gremlin.f ]] || wget https://www.pas.rochester.edu/~cline/Research/GOSIAcodes/gremlin.f
gfortran -O2 -std=legacy -ffixed-line-length-none gremlin.f -o gremlin
add_block "# GREMLIN" '# GREMLIN
export PATH="$HOME/GREMLIN:$PATH"'

# RadWare
clone_if_missing https://github.com/radforddc/rw05.git "$HOME/rw05"
cd "$HOME/rw05/src"
cp Makefile.linux Makefile
make all
make gtk
sed -i 's/[[:space:]]-lXp//g' Makefile
make xm
add_block "# RadWare" '# RadWare
export RADWARE_FONT_LOC="$HOME/rw05/font"
export RADWARE_ICC_LOC="$HOME/rw05/icc"
export RADWARE_GFONLINE_LOC="$HOME/rw05/doc"
export RADWARE_CURSOR_BELL=n
export RADWARE_OVERWRITE_FILE=ask
export RADWARE_AWAIT_RETURN=n
export RADWARE_XMG_SIZE=600x500
export PATH="$HOME/rw05/src:$PATH"'

# Scientific Python
if [[ ! -d "$HOME/venvs/nuclear-physics" ]]; then
  python3 -m venv "$HOME/venvs/nuclear-physics"
fi
source "$HOME/venvs/nuclear-physics/bin/activate"
python -m pip install --upgrade pip
python -m pip install numpy scipy matplotlib pandas jupyterlab uproot awkward iminuit
deactivate

# Nilsson code
clone_if_missing https://github.com/wimmer-k/Nilsson.git "$HOME/Nilsson"
if [[ ! -d "$HOME/venvs/nilsson" ]]; then
  python3 -m venv "$HOME/venvs/nilsson"
fi
source "$HOME/venvs/nilsson/bin/activate"
python -m pip install --upgrade pip
python -m pip install "numpy==1.26.4" "contourpy==1.3.3" matplotlib
python -m pip check
deactivate

# Nuclear Chart Plotter
mkdir -p "$HOME/NuclearChart"
clone_if_missing https://github.com/jonas-ka/nuclear-chart-plotter.git "$HOME/NuclearChart/nuclear-chart-plotter"
if [[ ! -d "$HOME/NuclearChart/nuclear-chart-env" ]]; then
  python3 -m venv "$HOME/NuclearChart/nuclear-chart-env"
fi
source "$HOME/NuclearChart/nuclear-chart-env/bin/activate"
python -m pip install --upgrade pip
python -m pip install numpy matplotlib pandas scipy jupyter
deactivate

# CUBIX
mkdir -p "$HOME/Cubix"
clone_if_missing https://gitlab.in2p3.fr/ip2igamma/cubix/cubix "$HOME/Cubix/cubix-sources"
git -C "$HOME/Cubix/cubix-sources" fetch --tags
git -C "$HOME/Cubix/cubix-sources" switch --detach "$CUBIX_VERSION"
cmake -S "$HOME/Cubix/cubix-sources" -B "$HOME/Cubix/cubix-build" \
  -DCMAKE_INSTALL_PREFIX="$HOME/Cubix/cubix-install" \
  -DBUILTIN_TKN=ON
cmake --build "$HOME/Cubix/cubix-build" --target install --parallel "$JOBS"
source "$HOME/Cubix/cubix-install/bin/thiscubix.sh" >/dev/null
add_block "# CUBIX" '# CUBIX
if [ -f "$HOME/Cubix/cubix-install/bin/thiscubix.sh" ]; then
    source "$HOME/Cubix/cubix-install/bin/thiscubix.sh" >/dev/null
fi'

# Geant4
mkdir -p "$HOME/G4"
cd "$HOME/G4"
if [[ ! -d "geant4-v$G4_VERSION" ]]; then
  [[ -f "geant4-v$G4_VERSION.tar.gz" ]] || wget "https://gitlab.cern.ch/geant4/geant4/-/archive/v$G4_VERSION/geant4-v$G4_VERSION.tar.gz"
  tar -xzf "geant4-v$G4_VERSION.tar.gz"
fi
cmake -S "$HOME/G4/geant4-v$G4_VERSION" -B "$HOME/G4/geant4-v$G4_VERSION-build" \
  -DCMAKE_INSTALL_PREFIX="$HOME/G4/geant4-v$G4_VERSION-install" \
  -DCMAKE_BUILD_TYPE=Release \
  -DGEANT4_BUILD_MULTITHREADED=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_GDML=ON
cmake --build "$HOME/G4/geant4-v$G4_VERSION-build" --parallel "$JOBS"
cmake --install "$HOME/G4/geant4-v$G4_VERSION-build"
add_block "# Geant4 $G4_VERSION" '# Geant4 11.4.2
if [ -f "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" ]; then
    source "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" >/dev/null
fi'

echo
echo "Installation complete."
echo "Open a new terminal and run: bash check-installation.sh"
