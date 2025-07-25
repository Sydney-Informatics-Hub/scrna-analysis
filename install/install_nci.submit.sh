#!/bin/bash
#PBS -q copyq
#PBS -l mem=8GB
#PBS -l jobfs=64GB
#PBS -l walltime=04:00:00
#PBS -l wd

if [ -z "${PREFIX}" ]; then PREFIX="/g/data/${PROJECT}"; fi

set -euo pipefail

export R_LIBS_USER="${PREFIX%/}/R/scrna-analysis/4.4"
if [ -d "${R_LIBS_USER}" ]; then echo "R library path ${R_LIBS_USER} already exists. Please remove it or choose a new PREFIX."; exit 1; fi
mkdir -p ${R_LIBS_USER}

# Load NCI modules for building packages
module load R/4.4.2
module load intel-compiler/2021.10.0
module load intel-mkl/2025.0.1
module load glpk/5.0
module load hdf5/1.12.2p
module load openmpi/5.0.5
module load gcc/14.2.0

# Use gcc/g++ for compiling C/C++
mkdir -p ${HOME}/.R
MKVARS=false
if [ -f "${HOME}/.R/Makevars" ]
then
    MKVARS=true
    mv ${HOME}/.R/Makevars ${HOME}/.R/_Makevars
fi

echo -e "CXX=g++
CXX11=g++
CXX14=g++
CXX17=g++
CXX20=g++
CC=gcc" > ${HOME}/.R/Makevars

# Install packages
SCRIPTFILE="install.R"
if [ ! -f "$SCRIPTFILE" ]; then SCRIPTFILE="install/install.R"; fi
if [ ! -f "$SCRIPTFILE" ]; then echo "Error: Cannot find install.R script. Exiting."; exit 1; fi
Rscript "${SCRIPTFILE}"

# Restore original Makevars file or comment out new lines
if $MKVARS
then
    mv ${HOME}/.R/_Makevars ${HOME}/.R/Makevars
else
    echo -e "# CXX=g++
    # CXX11=g++
    # CXX14=g++
    # CXX17=g++
    # CXX20=g++
    # CC=gcc" > .R/Makevars
fi
