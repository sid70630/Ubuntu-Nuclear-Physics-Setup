# Ubuntu Nuclear Physics Setup

Installation notes for nuclear-physics software on a native Ubuntu 24.04 LTS system.

The commands in this repository were tested on Ubuntu 24.04.2 LTS (x86_64). Install one program at a time when diagnosing a problem. The toolkit installer is provided for a new machine after the individual procedures have been reviewed.

## Contents

- [Install everything](#install-everything)
- [ROOT](#root)
- [GRSISort](#grsisort)
- [GOSIA and GOSIA2](#gosia-and-gosia2)
- [GREMLIN](#gremlin)
- [RadWare](#radware)
- [Geant4](#geant4)
- [CUBIX](#cubix)
- [Nilsson code](#nilsson-code)
- [Nuclear Chart Plotter](#nuclear-chart-plotter)
- [Python and JupyterLab](#python-and-jupyterlab)
- [LISE++](#lise)
- [NuShellX](#nushellx)
- [Licences and references](#licences-and-references)

## Install everything

Clone this repository and run:

```bash
git clone https://github.com/sid70630/Ubuntu-Nuclear-Physics-Setup.git
cd Ubuntu-Nuclear-Physics-Setup
bash install-toolkit.sh
```

The script installs each supported package in sequence. Existing installation directories are not overwritten. Geant4 is included and can take a long time to compile. LISE++, NuShellX and CUBIX remain manual steps.

Check the installation at any time with:

```bash
bash check-installation.sh
```

Open a new terminal after the installer finishes.

## ROOT

Original project: [CERN ROOT](https://root.cern/)

Install the required packages:

```bash
sudo apt update
sudo apt install -y \
  binutils cmake dpkg-dev g++ gcc git wget \
  libssl-dev libx11-dev libxext-dev libxft-dev libxpm-dev \
  python3 libtbb-dev libvdt-dev libgif-dev
```

Download the Ubuntu 24.04 binary release used in this guide:

```bash
cd ~
wget https://root.cern/download/root_v6.32.24.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz
tar -xzf root_v6.32.24.Linux-ubuntu24.04-x86_64-gcc13.3.tar.gz
source ~/root/bin/thisroot.sh
```

Add ROOT to future terminal sessions:

```bash
printf '\n# CERN ROOT 6.32.24\nsource "$HOME/root/bin/thisroot.sh"\n' >> ~/.bashrc
```

Test:

```bash
root-config --version
root -l -b -q -e 'std::cout << "ROOT test: " << gROOT->GetVersion() << std::endl;'
python3 -c 'import ROOT; print("PyROOT test:", ROOT.gROOT.GetVersion())'
```

See the [ROOT installation page](https://root.cern/install/) before using another Ubuntu or compiler version.

## GRSISort

Original project: [GRIFFINCollaboration/GRSISort](https://github.com/GRIFFINCollaboration/GRSISort)

GRSISort requires ROOT.

```bash
sudo apt install -y libblas-dev liblapack-dev
cd ~
git clone --recursive https://github.com/GRIFFINCollaboration/GRSISort.git
cd ~/GRSISort
source ./thisgrsi.sh
make -j"$(nproc)"
```

Add GRSISort to future terminal sessions:

```bash
printf '\n# GRSISort\nsource "$HOME/GRSISort/thisgrsi.sh"\n' >> ~/.bashrc
```

Test:

```bash
grsisort --version
ldd "$(command -v grsisort)" | grep "not found" || echo "No missing libraries"
```

## GOSIA and GOSIA2

Source archive: [GOSIA versions maintained by Nigel Warr](https://apps.ikp.uni-koeln.de/~warr/gosia/)

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

The [GOSIA project page](https://www.slcj.uw.edu.pl/en/gosia-code/) should also be consulted for documentation and references.

## GREMLIN

Original source: [GREMLIN on the Rochester GOSIA page](https://www.pas.rochester.edu/~cline/Research/GOSIA.htm)

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

Original project: [radforddc/rw05](https://github.com/radforddc/rw05)

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

Add RadWare to future terminal sessions:

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
export PATH="$PATH:$HOME/rw05/src"
EOF
```

Open a new terminal and test:

```bash
xmesc
```

## Geant4

Original project: [Geant4 at CERN](https://geant4.web.cern.ch/)

Install the build requirements:

```bash
sudo apt install -y \
  cmake g++ libxerces-c-dev libglu1-mesa-dev libxmu-dev \
  qt6-base-dev libqt6opengl6-dev
```

Download and configure Geant4 11.4.2:

```bash
mkdir -p ~/G4
cd ~/G4
wget https://gitlab.cern.ch/geant4/geant4/-/archive/v11.4.2/geant4-v11.4.2.tar.gz
tar -xzf geant4-v11.4.2.tar.gz

cmake -S ~/G4/geant4-v11.4.2 -B ~/G4/geant4-v11.4.2-build \
  -DCMAKE_INSTALL_PREFIX="$HOME/G4/geant4-v11.4.2-install" \
  -DCMAKE_BUILD_TYPE=Release \
  -DGEANT4_BUILD_MULTITHREADED=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_GDML=ON
```

Build and install:

```bash
cmake --build ~/G4/geant4-v11.4.2-build --parallel 4
cmake --install ~/G4/geant4-v11.4.2-build
printf '\n# Geant4 11.4.2\nsource "$HOME/G4/geant4-v11.4.2-install/bin/geant4.sh"\n' >> ~/.bashrc
```

Test in a new terminal:

```bash
geant4-config --version
geant4-config --features
```

## CUBIX

Original project: [IP2I Gamma CUBIX](https://gitlab.in2p3.fr/ip2igamma/cubix/cubix)

CUBIX is a ROOT-based graphical program for gamma-ray spectroscopy. Its requirements and installation procedure can change with ROOT and TkN releases. Follow the current [CUBIX installation guide](https://cubix.in2p3.fr/install/install/) and clone the project from its original GitLab repository. Do not copy a CUBIX source tree into this repository.

## Nilsson code

Original project: [wimmer-k/Nilsson](https://github.com/wimmer-k/Nilsson)

```bash
cd ~
git clone https://github.com/wimmer-k/Nilsson.git
python3 -m venv ~/venvs/nilsson
source ~/venvs/nilsson/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy matplotlib
cd ~/Nilsson
python nilsson.py -N 2
deactivate
```

The upstream repository did not display a licence file when this guide was prepared. Check with the author before redistributing or modifying the code.

## Nuclear Chart Plotter

Original project: [jonas-ka/nuclear-chart-plotter](https://github.com/jonas-ka/nuclear-chart-plotter)

```bash
cd ~
git clone https://github.com/jonas-ka/nuclear-chart-plotter.git
source ~/venvs/nuclear-physics/bin/activate
python -m pip install pandas numpy matplotlib jupyter
cd ~/nuclear-chart-plotter
jupyter lab
```

This project is released under the [MIT License](https://github.com/jonas-ka/nuclear-chart-plotter/blob/master/LICENSE), copyright Jonas Karthein. The copyright notice and licence must remain with copies or substantial portions of the software.

## Python and JupyterLab

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

## LISE++

Original project and downloads: [LISE++ at FRIB](https://lise.frib.msu.edu/)

LISE++ is freeware distributed under the [LISE++ user licence](https://lise.frib.msu.edu/doc/License.pdf). Read and accept the current licence, then use the Linux instructions supplied on the official site. The toolkit does not download or redistribute LISE++.

## NuShellX

NuShellX is distributed separately by its authors and is not downloaded by this repository. Obtain an authorised copy and follow the instructions supplied with it.

[NUTBAR](https://github.com/ragnarstroberg/nutbar) is a separate companion program. It is not NuShellX.

## Licences and references

This repository contains installation notes and scripts. It does not redistribute the source code or binaries of the programs listed above. Each program remains subject to its own licence, citation requirements and documentation.

See [THIRD_PARTY.md](THIRD_PARTY.md) before redistributing any downloaded program.

This guide was initially adapted from [UWCNuclear/UbuntuSetUp](https://github.com/UWCNuclear/UbuntuSetUp). The commands were subsequently retested and revised for native Ubuntu 24.04 LTS.
