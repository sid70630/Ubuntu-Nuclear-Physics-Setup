# Nuclear-physics software setup on Ubuntu

An installation guide for a 64-bit Ubuntu workstation used for nuclear-physics analysis and simulation.

## Supported systems

- Ubuntu 22.04.5 LTS (64-bit)
- Ubuntu 24.04 LTS (64-bit)

Commands should also work on later Ubuntu LTS releases unless a package has been renamed. Run each section separately and read any installer output before continuing.

> [!IMPORTANT]
> Do not paste an entire section into a terminal without reading it. Software versions, download filenames and dependencies change over time. Follow the linked official documentation when it differs from this guide.

## Contents

1. [Install or update Ubuntu](#1-install-or-update-ubuntu)
2. [Install common development tools](#2-install-common-development-tools)
3. [Install CERN ROOT](#3-install-cern-root)
4. [Install GRSISort](#4-install-grsisort)
5. [Install Geant4](#5-install-geant4)
6. [Install GOSIA](#6-install-gosia)
7. [Install GREMLIN](#7-install-gremlin)
8. [Install RadWare](#8-install-radware)
9. [Install NuShellX](#9-install-nushellx)
10. [Install Python and Jupyter](#10-install-python-and-jupyter)
11. [Troubleshooting and maintenance](#11-troubleshooting-and-maintenance)

## 1. Install or update Ubuntu

Install a supported 64-bit Ubuntu LTS release from the [official Ubuntu download page](https://ubuntu.com/download/desktop).

After installation:

```bash
sudo apt update
sudo apt full-upgrade
sudo reboot
```

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

GRSISort is a ROOT-based nuclear-physics analysis toolkit. Install and activate a compatible ROOT version before continuing.

Install the BLAS runtime and development packages:

```bash
sudo apt update
sudo apt install --yes libblas3 libblas-dev
```

Download GRSISort into your home directory:

```bash
cd "$HOME"
git clone https://github.com/GRIFFINCollaboration/GRSISort.git
cd GRSISort
```

Activate its environment and compile:

```bash
source thisgrsi.sh
make -j"$(nproc)"
```

Add the setup command once so that new Bash sessions can find GRSISort:

```bash
printf '\nsource "$HOME/GRSISort/thisgrsi.sh"\n' >> "$HOME/.bashrc"
source "$HOME/.bashrc"
```

Test it:

```bash
grsisort -l -q
```

ROOT commands should also work inside GRSISort. Older GRSISort branches may require an older compatible ROOT release, so confirm the supported combination before changing either version.

- [GRSISort setup guide](https://github.com/GRIFFINCollaboration/GRSISort/wiki/Setting-up-GRSISort)
- [GRSISort troubleshooting](https://github.com/GRIFFINCollaboration/GRSISort/wiki/troubleshooting)

## 5. Install Geant4

Use the current Geant4 release from the [official download page](https://geant4.web.cern.ch/download/). Do not install the old Geant4 10.06 release unless a specific project requires it.

Install typical build and visualisation dependencies:

```bash
sudo apt update
sudo apt install --yes \
  build-essential cmake ninja-build \
  libxerces-c-dev libexpat1-dev \
  libx11-dev libxmu-dev libxi-dev \
  qt6-base-dev
```

After downloading `geant4-v<VERSION>.tar.gz`, replace `<VERSION>` below with the downloaded version number:

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

Test the installation using Geant4's Basic Example B1:

```bash
mkdir -p "$HOME/software/geant4/examples/B1-build"
cp -r "$HOME/software/geant4/source/examples/basic/B1" \
      "$HOME/software/geant4/examples/"

cmake -S "$HOME/software/geant4/examples/B1" \
      -B "$HOME/software/geant4/examples/B1-build" \
      -DCMAKE_PREFIX_PATH="$HOME/software/geant4/install"

cmake --build "$HOME/software/geant4/examples/B1-build" --parallel
cd "$HOME/software/geant4/examples/B1-build"
./exampleB1
```

In the Geant4 session, run:

```text
/run/beamOn 10
```

Consult the current [Geant4 Installation Guide](https://geant4.web.cern.ch/documentation/dev/ig_html/InstallationGuide/) for supported compilers and build options.

## 6. Install GOSIA

GOSIA is distributed separately and is not included in this repository. Obtain the source from the [GOSIA distribution page](https://www.ikp.uni-koeln.de/~warr/gosia/) or directly from its maintainers.

Install the current GNU Fortran compiler:

```bash
sudo apt update
sudo apt install --yes gfortran
```

Move the downloaded source to a dedicated directory, adjusting the filename if necessary:

```bash
mkdir -p "$HOME/software/gosia"
mv "$HOME/Downloads/gosia_20110524.9.f" "$HOME/software/gosia/"
cd "$HOME/software/gosia"
```

Compile legacy fixed-form Fortran source with:

```bash
gfortran -O2 -std=legacy -ffixed-line-length-none \
  -o gosia gosia_20110524.9.f
```

Run GOSIA with an input file:

```bash
./gosia < filename.inp
```

Sample material may also be available from the [GOSIA support page](http://www.pas.rochester.edu/~cline/Gosia/). Yield-integration scripts are available from [UWCNuclear/IntegratedYields](https://github.com/UWCNuclear/IntegratedYields); review that repository's instructions and licence separately.

## 7. Install GREMLIN

GREMLIN is distributed separately and its source is not included here. Obtain `gremlin.f` from an authorised GOSIA/GREMLIN distribution.

Install the compiler:

```bash
sudo apt update
sudo apt install --yes gfortran
```

Compile the fixed-form legacy source:

```bash
mkdir -p "$HOME/software/gremlin"
mv "$HOME/Downloads/gremlin.f" "$HOME/software/gremlin/"
cd "$HOME/software/gremlin"

gfortran -O2 -std=legacy -ffixed-line-length-none \
  -o gremlin gremlin.f
```

The `-ffixed-line-length-none` option prevents long fixed-form source lines from being truncated at column 72. This is preferable to manually changing valid expressions merely to shorten their lines.

Test the executable:

```bash
./gremlin
```

Compiler warnings from legacy Fortran are possible, but compilation errors must be investigated rather than ignored.

## 8. Install RadWare

Install the required compilers and graphical libraries:

```bash
sudo apt update
sudo apt install --yes \
  build-essential git libreadline-dev libgtk2.0-dev \
  libmotif-dev libxpm-dev libxt-dev libxext-dev \
  xfonts-75dpi xfonts-100dpi
```

Download the Linux/Unix RadWare source:

```bash
cd "$HOME"
git clone https://github.com/radforddc/rw05.git
cd "$HOME/rw05/src"
cp Makefile.linux Makefile
```

Open `Makefile` in your preferred editor. Set the installation directory to:

```makefile
INSTALL_DIR = ${HOME}/rw05
```

If the linker cannot find `libXp`, remove or comment out only the `-lXp` entries specified by the current Makefile documentation. Avoid adding `-o USERNAME -g users` to the install commands; installing inside your home directory does not require changing file ownership.

Build the standard programs and the graphical variants you need:

```bash
make all
make gtk
make xm
```

Add the RadWare environment variables once:

```bash
cat >> "$HOME/.bashrc" <<'EOF'

# RadWare
export RADWARE_FONT_LOC="$HOME/rw05/font"
export RADWARE_ICC_LOC="$HOME/rw05/icc"
export RADWARE_GFONLINE_LOC="$HOME/rw05/doc"
export PATH="$PATH:$HOME/rw05/src"
export RADWARE_CURSOR_BELL=n
export RADWARE_OVERWRITE_FILE=ask
export RADWARE_AWAIT_RETURN=n
export RADWARE_XMG_SIZE=600x500
EOF

source "$HOME/.bashrc"
```

Test the installation:

```bash
xmesc
```

More information: [RadWare source](https://github.com/radforddc/rw05) and [RadWare documentation](https://radware.phy.ornl.gov/).

## 9. Install NuShellX

NuShellX is distributed separately. Obtain an authorised Linux package and its documentation; do not copy or publish its executables or data files without permission.

After extracting an authorised package as `$HOME/nushellx`, inspect the directory names and then add only the required environment variables:

```bash
cat >> "$HOME/.bashrc" <<'EOF'

# NuShellX
export NUSHELLX_HOME="$HOME/nushellx"
export PATH="$NUSHELLX_HOME/linux/nushellx-gfortran-bin:$PATH"
export nushellx_sps="$NUSHELLX_HOME/sps/"
export mass_data="$NUSHELLX_HOME/toi/mass-data/"
export toi_data="$NUSHELLX_HOME/toi/toi-data/"
EOF

source "$HOME/.bashrc"
chmod u+x "$HOME"/nushellx/linux/nushellx-gfortran-bin/*
```

Do not add cluster-specific aliases such as `qstat`, `checknode`, or aliases that replace standard commands unless your local computing centre explicitly requires them. Consult `nushellx/help/help.pdf` supplied with the authorised package.

## 10. Install Python and Jupyter

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

## 11. Troubleshooting and maintenance

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

- Ubuntu release
- software version or Git commit
- compiler and CMake versions
- the command that failed
- the complete error message

## Scope and acknowledgement

This is an independently written guide maintained by [Siddharth Doshi](https://github.com/sid70630). It was motivated by the public [UWCNuclear UbuntuSetUp repository](https://github.com/UWCNuclear/UbuntuSetUp), but it does not reproduce that repository's documentation or bundled source files.

Product names and external projects belong to their respective owners. Always consult each project's licence and official documentation before redistributing its code.
