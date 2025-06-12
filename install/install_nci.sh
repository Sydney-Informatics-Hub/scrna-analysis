#!/bin/bash
#PBS -q copyq
#PBS -P proj01
#PBS -l mem=8GB
#PBS -l jobfs=64GB
#PBS -l storage=scratch/proj01
#PBS -l walltime=04:00:00
#PBS -l wd

set -euo pipefail

SCRIPTPATH="$(realpath $0)"
SCRIPTDIR="$(dirname $SCRIPTPATH)"

export R_LIBS_USER=${HOME}/R/x86_64-pc-linux-gnu-library/4.4
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
CC=gcc" > ${HOME}/.R/Makevars

# Install packages
Rscript "${SCRIPTDIR}/install.R"

# Restore original Makevars file or comment out new lines
if $MKVARS
then
    mv ${HOME}/.R/_Makevars ${HOME}/.R/Makevars
else
    echo -e "# CXX=g++
    # CXX11=g++
    # CXX14=g++
    # CXX17=g++
    # CC=gcc" > .R/Makevars
fi
