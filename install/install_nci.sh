#!/bin/bash
#PBS -q copyq
#PBS -l mem=8GB
#PBS -l jobfs=10GB
#PBS -l walltime=10:00:00
#PBS -l wd

set -euo pipefail

# edit below to suit your case
export R_VERSION="4.4.2"
export R_LIB_NAME="${R_VERSION}_scrna-analysis"

# configurations
export CRAN_MIRROR="https://cran.csiro.au/"

# Final Path
PREFIX="/scratch/${PROJECT}/${USER}/R"
export R_LIBS="${PREFIX}/${R_LIB_NAME}"
export R_LIB_CACHE_PATH="${PBS_JOBFS}/${R_LIB_NAME}/"

mkdir -p ${R_LIBS}
mkdir -p ${R_LIB_CACHE_PATH}

module load R/$R_VERSION
module load intel-compiler/2021.10.0 
module load gcc/14.2.0
module load hdf5/1.12.2p
module load openmpi/5.0.5

MAKEVARS_EXISTS=false
MAKEVARS_DIR="${HOME}/.R"
MAKEVARS_FILE="${MAKEVARS_DIR}/Makevars"
MAKEVARS_TMPFILE="${MAKEVARS_DIR}/.R_Makevars"
if [ -f "${MAKEVARS_FILE}" ]; then
    MAKEVARS_EXISTS=true
    mv "${MAKEVARS_FILE}" "${MAKEVARS_TMPFILE}"
else
    mkdir -p "${MAKEVARS_DIR}"
fi

R -e "install.packages('here', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('here')"

echo -e "CXX=g++
CXX11=g++
CXX14=g++
CXX17=g++
CXX20=g++
CC=gcc" > ${MAKEVARS_FILE}

R -e "install.packages('devtools', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('devtools')"
R -e "install.packages('tidyverse', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('tidyverse')"
R -e "install.packages('Seurat', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('Seurat')"
R -e "install.packages('hdf5r', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('hdf5r')"
R -e "install.packages('clustree', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('clustree')"
R -e "install.packages('DT', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('DT')"
R -e "install.packages('shiny', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('shiny')"
R -e "install.packages('ggplot2', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('ggplot2')"
R -e "install.packages('ggrepel', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('ggrepel')"
R -e "install.packages('WebGestaltR', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('WebGestaltR')"
R -e "install.packages('BiocManager', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('BiocManager')"
R -e "install.packages('remotes', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('remotes')"
R -e "install.packages('htmltools', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('htmltools')"
R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('DoubletFinder')"
R -e "remotes::install_github('immunogenomics/presto', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('presto')"
R -e "remotes::install_github('bnprks/BPCells/r', lib='${R_LIBS}', repos='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}'); library('BPCells')"
R -e "BiocManager::install('SingleCellExperiment', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('SingleCellExperiment')"
R -e "BiocManager::install('SingleR', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('SingleR')"
R -e "BiocManager::install('celldex', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('celldex')"

echo -e "CXX=g++
CXX11=g++
CXX14=g++
CXX17=g++
CXX20=g++
CXX11STD=-std=c++14
CC=gcc" > ${MAKEVARS_FILE}

R -e "BiocManager::install('glmGamPoi', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('glmGamPoi')"

echo -e "CXX=g++
CXX11=g++
CXX14=g++
CXX17=g++
CXX20=g++
CC=gcc" > ${MAKEVARS_FILE}

R -e "BiocManager::install('scuttle', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('scuttle')"
R -e "BiocManager::install('DESeq2', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('DESeq2')"
R -e "BiocManager::install('EnsDb.Hsapiens.v86', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('EnsDb.Hsapiens.v86')"
R -e "BiocManager::install('EnsDb.Mmusculus.v79', lib='${R_LIBS}', site_repository='${CRAN_MIRROR}', destdir='${R_LIB_CACHE_PATH}', ask=FALSE); library('EnsDb.Mmusculus.v79')"

if ${MAKEVARS_EXISTS}; then
    mv .R_Makevars ${MAKEVARS_FILE}
else
    rm ${MAKEVARS_FILE}
fi

# Fix permissions
chmod -R g=u ${R_LIBS}
chmod -R g=u ${R_LIB_CACHE_PATH}
