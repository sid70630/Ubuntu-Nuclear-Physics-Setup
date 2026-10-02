# Ubuntu Nuclear Physics Setup

Installation notes for nuclear-physics software on native Ubuntu 24.04 LTS.

These commands were tested on Ubuntu 24.04.2 LTS (x86_64). The programs are downloaded from their developers' websites or repositories. This repository does not contain or redistribute their source code or binaries.

## Contents

- [Install the toolkit](#install-the-toolkit)
- [ROOT](#root)
- [GRSISort](#grsisort)
- [GOSIA and GOSIA2](#gosia-and-gosia2)
- [GREMLIN](#gremlin)
- [RadWare](#radware)
- [Python and JupyterLab](#python-and-jupyterlab)
- [Nilsson code](#nilsson-code)
- [Nuclear Chart Plotter](#nuclear-chart-plotter)
- [CUBIX](#cubix)
- [Geant4](#geant4)
- [LISE++](#lise)

## Install the toolkit

Clone this repository:

```bash
git clone https://github.com/sid70630/Ubuntu-Nuclear-Physics-Setup.git
cd Ubuntu-Nuclear-Physics-Setup
```

Run the complete installer:

```bash
bash install-toolkit.sh
```

It installs ROOT, GRSISort, GOSIA/GOSIA2, GREMLIN, RadWare, the Python environment, the Nilsson code, Nuclear Chart Plotter, CUBIX and Geant4. 

LISE++ needs to be installed manually.

Check all installations with:

```bash
bash check-installation.sh
```

## ROOT

ROOT is a data-analysis framework widely used for histogramming, fitting, visualisation, C++ analysis and PyROOT.

Ref: [CERN ROOT](https://root.cern/)

```bash
sudo apt update
sudo apt install -y \
  binutils cmake dpkg-dev g++ gcc git wget \
  libssl-dev libx11-dev libxext-dev libxft-dev libxpm-dev \
  python3 libtbb-dev libvdt-dev libgif-dev

cd ~
wget https://root.cern/download/root_v6.32.24.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz
tar -xzf root_v6.32.24.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz
source ~/root/bin/thisroot.sh
```

Add ROOT to new terminals:

```bash
cat >> ~/.bashrc <<'EOF'

# CERN ROOT 6.32.24
if [ -f "$HOME/root/bin/thisroot.sh" ]; then
    source "$HOME/root/bin/thisroot.sh" >/dev/null
fi
EOF
```

Test:

```bash
root-config --version
root -l -b -q -e 'std::cout << "ROOT test: " << gROOT->GetVersion() << std::endl;'
python3 -c 'import ROOT; print("PyROOT test:", ROOT.gROOT.GetVersion())'
```

## GRSISort

GRSISort is a ROOT-based analysis framework developed for GRIFFIN data. It is useful for calibration, event building, sorting and histogramming.

Ref: [GRIFFINCollaboration/GRSISort](https://github.com/GRIFFINCollaboration/GRSISort)

Note : ROOT must be installed first.

```bash
sudo apt install -y libblas-dev liblapack-dev
cd ~
git clone --recursive https://github.com/GRIFFINCollaboration/GRSISort.git
cd ~/GRSISort
source ./thisgrsi.sh
make -j"$(nproc)"
```

Add:

```bash
cat >> ~/.bashrc <<'EOF'

# GRSISort
if [ -f "$HOME/GRSISort/thisgrsi.sh" ]; then
    source "$HOME/GRSISort/thisgrsi.sh" >/dev/null
fi
EOF
```

Test:

```bash
grsisort --version
ldd "$(command -v grsisort)" | grep "not found" || echo "GRSISort: no missing libraries"
```

## GOSIA and GOSIA2

GOSIA fits Coulomb-excitation data to determine electromagnetic matrix elements. GOSIA2 extends the analysis to simultaneous projectile and target excitation.

Ref: [GOSIA source archive](https://apps.ikp.uni-koeln.de/~warr/gosia/)  
Ref: [GOSIA project page](https://www.slcj.uw.edu.pl/en/gosia-code/)

```bash
sudo apt install -y gfortran
mkdir -p ~/GOSIA
cd ~/GOSIA
wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia_20110524.13.f
wget https://apps.ikp.uni-koeln.de/~warr/gosia/gosia2_20081208.27.f
gfortran -O2 gosia_20110524.13.f -o gosia
gfortran -O2 gosia2_20081208.27.f -o gosia2
printf '\n# GOSIA and GOSIA2\nexport PATH="$HOME/GOSIA:$PATH"\n' >> ~/.bashrc
```

Test:

```bash
ldd ~/GOSIA/gosia | grep "not found" || echo "GOSIA: no missing libraries"
ldd ~/GOSIA/gosia2 | grep "not found" || echo "GOSIA2: no missing libraries"
```

## GREMLIN

GREMLIN fits gamma-ray efficiency calibrations and calculates line intensities. It is useful when converting measured peak areas into efficiency-corrected intensities.

Ref: [Rochester GOSIA page](https://www.pas.rochester.edu/~cline/Research/GOSIA.htm)

```bash
sudo apt install -y gfortran
mkdir -p ~/GREMLIN
cd ~/GREMLIN
wget https://www.pas.rochester.edu/~cline/Research/GOSIAcodes/gremlin.f
gfortran -O2 -std=legacy -ffixed-line-length-none gremlin.f -o gremlin
printf '\n# GREMLIN\nexport PATH="$HOME/GREMLIN:$PATH"\n' >> ~/.bashrc
```

Test:

```bash
printf '0\n' | ~/GREMLIN/gremlin
```

## RadWare

RadWare contains programs for analysing gamma-ray spectra, coincidence matrices and level schemes. Tools: GF3, GLS and ESCL8R/XMESC.

Ref: [radforddc/rw05](https://github.com/radforddc/rw05)  
Ref: [RadWare documentation](https://radware.phy.ornl.gov/)

```bash
sudo apt install -y \
  gcc make libreadline-dev libx11-dev libxext-dev \
  libgtk2.0-dev libmotif-dev xfonts-75dpi xfonts-100dpi

cd ~
git clone https://github.com/radforddc/rw05.git
cd ~/rw05/src
cp Makefile.linux Makefile
make all
make gtk
sed -i 's/[[:space:]]-lXp//g' Makefile
make xm
```

Add the environment:

```bash
cat >> ~/.bashrc <<'EOF'

# RadWare
export RADWARE_FONT_LOC="$HOME/rw05/font"
export RADWARE_ICC_LOC="$HOME/rw05/icc"
export RADWARE_GFONLINE_LOC="$HOME/rw05/doc"
export RADWARE_CURSOR_BELL=n
export RADWARE_OVERWRITE_FILE=ask
export RADWARE_AWAIT_RETURN=n
export RADWARE_XMG_SIZE=600x500
export PATH="$HOME/rw05/src:$PATH"
EOF
```

Test:

```bash
source ~/.bashrc
xmesc
```

## Python and JupyterLab

It includes NumPy, SciPy, pandas, Matplotlib, Uproot and JupyterLab.

```bash
sudo apt install -y python3-venv python3-pip
python3 -m venv ~/venvs/nuclear-physics
source ~/venvs/nuclear-physics/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy scipy matplotlib pandas jupyterlab uproot awkward iminuit
```

Test:

```bash
python -c 'import numpy, scipy, matplotlib, pandas, uproot, awkward, iminuit; print("Scientific Python imports: OK")'
jupyter lab --version
deactivate
```

Start it with:

```bash
source ~/venvs/nuclear-physics/bin/activate
jupyter lab
```

Stop the server with Ctrl+C, then run `deactivate`.

## Nilsson code

This Python code calculates and plots Nilsson single-particle levels as a function of deformation. 

Ref: [wimmer-k/Nilsson](https://github.com/wimmer-k/Nilsson)

```bash
cd ~
git clone https://github.com/wimmer-k/Nilsson.git
python3 -m venv ~/venvs/nilsson
source ~/venvs/nilsson/bin/activate
python -m pip install --upgrade pip
python -m pip install "numpy==1.26.4" "contourpy==1.3.3" matplotlib
cd ~/Nilsson
```

Test:

```bash
python nilsson.py -N 2 -noplot -w nilsson-test-N2.dat
head nilsson-test-N2.dat
```

Test the plot:

```bash
python nilsson.py -N 2
```

## Nuclear Chart Plotter

Nuclear Chart Plotter is a Jupyter-based tool for producing customised charts of nuclides and nuclear-property plots.

Ref: [jonas-ka/nuclear-chart-plotter](https://github.com/jonas-ka/nuclear-chart-plotter)

```bash
mkdir -p ~/NuclearChart
cd ~/NuclearChart
python3 -m venv nuclear-chart-env
source nuclear-chart-env/bin/activate
git clone https://github.com/jonas-ka/nuclear-chart-plotter.git
cd nuclear-chart-plotter
python -m pip install --upgrade pip
python -m pip install numpy matplotlib pandas scipy jupyter
jupyter lab nuclear-chart.ipynb
```

Stop Jupyter with Ctrl+C, then run `deactivate`.

## CUBIX

CUBIX is a ROOT-based graphical program for gamma-ray spectroscopy. 

Ref: [IP2I Gamma CUBIX](https://gitlab.in2p3.fr/ip2igamma/cubix/cubix)  
Ref: [CUBIX documentation](https://cubix.in2p3.fr/)

ROOT must be active and include MathMore support.

```bash
mkdir -p ~/Cubix
cd ~/Cubix
git clone https://gitlab.in2p3.fr/ip2igamma/cubix/cubix cubix-sources
git -C cubix-sources switch --detach v1.5

source ~/root/bin/thisroot.sh

cmake \
  -S ~/Cubix/cubix-sources \
  -B ~/Cubix/cubix-build \
  -DCMAKE_INSTALL_PREFIX="$HOME/Cubix/cubix-install" \
  -DBUILTIN_TKN=ON

cmake --build ~/Cubix/cubix-build \
  --target install \
  --parallel 4
```

Add:

```bash
cat >> ~/.bashrc <<'EOF'

# CUBIX
if [ -f "$HOME/Cubix/cubix-install/bin/thiscubix.sh" ]; then
    source "$HOME/Cubix/cubix-install/bin/thiscubix.sh" >/dev/null
fi
EOF
```

Test:

```bash
source ~/Cubix/cubix-install/bin/thiscubix.sh >/dev/null
cubix-config --version
tkn-config --version
ldd "$(command -v cubix)" | grep "not found" || echo "CUBIX: no missing libraries"
cubix
```

## Geant4

Geant4 simulates the passage of particles through matter. It is widely used for detector-response, efficiency, shielding and radiation-transport simulations.

Ref: [Geant4 at CERN](https://geant4.web.cern.ch/)  
Ref: [Geant4 installation guide](https://geant4-userdoc.web.cern.ch/UsersGuides/InstallationGuide/html/)

```bash
sudo apt install -y \
  cmake g++ libxerces-c-dev libglu1-mesa-dev libxmu-dev \
  qt6-base-dev libqt6opengl6-dev

mkdir -p ~/G4
cd ~/G4
wget https://gitlab.cern.ch/geant4/geant4/-/archive/v11.4.2/geant4-v11.4.2.tar.gz
tar -xzf geant4-v11.4.2.tar.gz

cmake --fresh \
  -S ~/G4/geant4-v11.4.2 \
  -B ~/G4/geant4-v11.4.2-build \
  -DCMAKE_INSTALL_PREFIX="$HOME/G4/geant4-v11.4.2-install" \
  -DCMAKE_BUILD_TYPE=Release \
  -DGEANT4_BUILD_MULTITHREADED=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_GDML=ON

cmake --build ~/G4/geant4-v11.4.2-build --parallel 4
cmake --install ~/G4/geant4-v11.4.2-build
```

Add:

```bash
cat >> ~/.bashrc <<'EOF'

# Geant4 11.4.2
if [ -f "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" ]; then
    source "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh" >/dev/null
fi
EOF
```

Test:

```bash
source ~/G4/geant4-v11.4.2-install/bin/geant4.sh
geant4-config --version
geant4-config --features
```

## LISE++

LISE++ is used to calculate rare-isotope production, fragment-separator transmission, reaction products, ion optics and energy loss. 

Ref: [LISE++ at FRIB](https://lise.frib.msu.edu/)  
Ref: [Linux downloads](https://lise.frib.msu.edu/download/)  
Ref: [LISE++ user licence](https://lise.frib.msu.edu/doc/License.pdf)

Read the licence and open the official Linux download page:

```bash
mkdir -p ~/LISE
firefox https://lise.frib.msu.edu/download/
```

Download the current Debian package using the browser. Direct `wget` requests may download an Incapsula HTML page instead of the package.

Move the downloaded file into `~/LISE`, verify it and install it:

```bash
mv ~/Downloads/lise-app*.deb ~/LISE/
cd ~/LISE

file lise-app*.deb
dpkg-deb --info lise-app*.deb | head
sudo apt install ./lise-app*.deb
```

The `file` command must report a Debian binary package. Do not run the installation if it reports an HTML document.

If LISE++ reports that `Qt_6.7` is missing even though the package contains its own Qt libraries, create a local launcher:

```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/lise++ <<'EOF'
#!/bin/sh
unset LD_LIBRARY_PATH
exec /usr/lib/lise-app/LISE++ "$@"
EOF

chmod +x ~/.local/bin/lise++
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc ||
  printf '\n# User commands\nexport PATH="$HOME/.local/bin:$PATH"\n' >> ~/.bashrc

source ~/.bashrc
hash -r
```

Test:

```bash
which lise++
lise++
```

## Note

This repository contains installation guide and scripts written for publicly available Software. I do not own the programs. All rights, licences and citation requirements remain with their respective authors. The original references are given in each section.

The guide was initially adapted from [UWCNuclear/UbuntuSetUp](https://github.com/UWCNuclear/UbuntuSetUp) and was retested for native Ubuntu 24.04 LTS.
