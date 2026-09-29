# Software setup on Ubuntu

An installation guide for a 64-bit Ubuntu.

## Supported systems

- Ubuntu 22.04.5 LTS (64-bit)
- Ubuntu 24.04 LTS (64-bit)
- Windows 11 with WSL 2 and Ubuntu 22.04 or newer

## Contents

1. [Install or update Ubuntu](#1-install-or-update-ubuntu)
2. [Install common development tools](#2-install-common-development-tools)
3. [Install CERN ROOT](#3-install-cern-root)
4. [Install GRSISort](#4-install-grsisort)
5. [Install Geant4](#5-install-geant4)
6. [Specialist and restricted software](#6-specialist-and-restricted-software)
7. [Python and Jupyter](#7-python-and-jupyter)
8. [Troubleshooting and maintenance](#8-troubleshooting-and-maintenance)

## 1. Install or update Ubuntu

### Native Ubuntu

Install a supported 64-bit Ubuntu LTS release from the [official Ubuntu download page](https://ubuntu.com/download/desktop).

After installation:

```bash
sudo apt update
sudo apt full-upgrade
sudo reboot
```

### Windows 11 with WSL 2

Open PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart Windows if requested, open Ubuntu, and create a Linux username and password. Confirm that the distribution uses WSL 2:

```powershell
wsl --list --verbose
```

If necessary:

```powershell
wsl --set-version Ubuntu-24.04 2
wsl --update
```

Modern WSL 2 includes support for Linux GUI applications through WSLg. Xming and a manually defined `DISPLAY` variable are normally unnecessary.

Official documentation: [Install WSL](https://learn.microsoft.com/windows/wsl/install) and [run Linux GUI applications](https://learn.microsoft.com/windows/wsl/tutorials/gui-apps).

## 2. Install common development tools

```bash
sudo apt update
sudo apt install --yes \
  build-essential cmake git curl wget pkg-config \
  gfortran python3 python3-pip python3-venv \
  libx11-dev libxpm-dev libxft-dev libxext-dev \
  libssl-dev libxml2-dev libgsl-dev
```

Check the main tools:

```bash
gcc --version
g++ --version
gfortran --version
cmake --version
git --version
python3 --version
```

## 3. Install CERN ROOT

ROOT provides official precompiled binaries and Conda packages. These are preferable to copying commands for an old, fixed ROOT release.

### Option A: precompiled ROOT binary

1. Open the [official ROOT installation page](https://root.cern/install/).
2. Select a binary built for your exact Ubuntu release and architecture.
3. Install the dependencies listed on the [ROOT dependencies page](https://root.cern/install/dependencies/).
4. Download and extract the archive. For example, after replacing `<root-archive>` with the downloaded filename:

```bash
mkdir -p "$HOME/software/root"
tar -xzf "$HOME/Downloads/<root-archive>.tar.gz" \
  --strip-components=1 -C "$HOME/software/root"
```

Activate ROOT for the current terminal:

```bash
source "$HOME/software/root/bin/thisroot.sh"
```

To activate it automatically, add the command once:

```bash
printf '\nsource "$HOME/software/root/bin/thisroot.sh"\n' >> "$HOME/.bashrc"
```

Test the installation:

```bash
root-config --version
root -l -q
```

### Option B: Conda environment

Install Miniforge from its [official repository](https://github.com/conda-forge/miniforge), then create an isolated environment:

```bash
conda create --name root-env --channel conda-forge root
conda activate root-env
root-config --version
```

Do not mix a Conda ROOT installation with another ROOT installation in the same terminal.

## 4. Install GRSISort

GRSISort must be built against a compatible ROOT installation. Start in a fresh terminal, activate ROOT, and then run:

```bash
cd "$HOME"
git clone https://github.com/GRIFFINCollaboration/GRSISort.git
cd GRSISort
source thisgrsi.sh
make -j"$(nproc)"
```

Test the shell configuration:

```bash
grsisort --help
```

Before choosing a branch or ROOT version, read the current [GRSISort setup documentation](https://github.com/GRIFFINCollaboration/GRSISort/wiki/Setting-up-GRSISort).

## 5. Install Geant4

Use the current Geant4 release from the [official download page](https://geant4.web.cern.ch/download/). The example below deliberately uses placeholders so that the guide does not silently install an obsolete release.

Install typical build and visualisation dependencies:

```bash
sudo apt update
sudo apt install --yes \
  build-essential cmake ninja-build \
  libxerces-c-dev libexpat1-dev \
  libx11-dev libxmu-dev libxi-dev \
  qt6-base-dev
```

After downloading `geant4-v<VERSION>.tar.gz`:

```bash
mkdir -p "$HOME/software/geant4/source" \
         "$HOME/software/geant4/build" \
         "$HOME/software/geant4/install"

tar -xzf "$HOME/Downloads/geant4-v<VERSION>.tar.gz" \
  --strip-components=1 -C "$HOME/software/geant4/source"

cmake -S "$HOME/software/geant4/source" \
      -B "$HOME/software/geant4/build" \
      -G Ninja \
      -DCMAKE_INSTALL_PREFIX="$HOME/software/geant4/install" \
      -DGEANT4_INSTALL_DATA=ON \
      -DGEANT4_USE_OPENGL_X11=ON \
      -DGEANT4_USE_QT=ON

cmake --build "$HOME/software/geant4/build" --parallel
cmake --install "$HOME/software/geant4/build"
source "$HOME/software/geant4/install/bin/geant4.sh"
```

Verify the installation:

```bash
geant4-config --version
geant4-config --features
```

Consult the current [Geant4 Installation Guide](https://geant4.web.cern.ch/documentation/dev/ig_html/InstallationGuide/) for supported compilers and build options.

## 6. Specialist and restricted software

The following packages need separate, package-specific instructions. Their source files are not redistributed in this repository.

### GOSIA

Obtain GOSIA from its official maintainers or distribution page. Confirm the required compiler version before building; do not install an obsolete GCC release merely because an old guide specifies it.

### GREMLIN

Obtain the GREMLIN source from its authorised distributor. A typical Fortran build may use `gfortran`, but compiler flags depend on the source version and must be tested before being documented here.

### RadWare

Use David Radford's maintained [RadWare source repository](https://github.com/radforddc/rw05) and follow its current README or Makefile instructions. Do not replace usernames or ownership fields in install commands without understanding their effect.

### NuShellX

NuShellX is distributed separately. Obtain it through its authorised distribution route and follow the documentation supplied with that version. Do not upload its binaries or data files to this repository unless redistribution permission explicitly allows it.

Dedicated, tested installation pages can be added later for each package.

## 7. Python and Jupyter

Use an isolated virtual environment rather than installing scientific packages globally:

```bash
python3 -m venv "$HOME/venvs/nuclear-physics"
source "$HOME/venvs/nuclear-physics/bin/activate"
python -m pip install --upgrade pip
python -m pip install numpy scipy matplotlib pandas jupyterlab uproot
```

Start JupyterLab:

```bash
jupyter lab
```

Leave the environment with:

```bash
deactivate
```

## 8. Troubleshooting and maintenance

Show the Ubuntu release and architecture:

```bash
lsb_release -a
uname -m
```

The architecture should normally be `x86_64` on a 64-bit Intel or AMD machine.

Update Ubuntu packages:

```bash
sudo apt update
sudo apt full-upgrade
```

When reporting a problem, include:

- Ubuntu release and whether it is native Ubuntu or WSL 2
- software version or Git commit
- compiler and CMake versions
- the command that failed
- the complete error message

## Scope and acknowledgement

This is an independently written guide maintained by [Siddharth Doshi](https://github.com/sid70630). It was motivated by the public [UWCNuclear UbuntuSetUp repository](https://github.com/UWCNuclear/UbuntuSetUp), but it does not reproduce that repository's documentation or bundled source files.

Product names and external projects belong to their respective owners. Always consult each project's licence and official documentation before redistributing its code.

