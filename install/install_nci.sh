#!/bin/bash

set -euo pipefail

# Get optional commandline arguments
POS=()
PROJ=""
PREFIX=""
SUBMIT=false
while [[ "$#" -gt 0 ]]
do
    case $1 in
        --project)
            PROJ="$2"
            shift
            shift
            ;;
        --prefix)
            PREFIX="${2%/}"
            shift
            shift
            ;;
        --submit)
            SUBMIT=true
            shift
            ;;
        *)
            POS+=("$1")
            shift
            ;;
    esac
done

set -- "${POS[@]}"

# Set defaults if not set by commandline arguments
if [ -z "${PROJ}" ]; then PROJ="${PROJECT}"; fi
if [ -z "${PREFIX}" ]
then
    PREFIX="/g/data/${PROJ}"
    if [ ! -d "${PREFIX}" ]; then PREFIX="/scratch/${PROJ}"; fi
fi

# Define R library path and check it doesn't exist
RLIBS="${PREFIX}/R/scrna-analysis/4.4"
if [ -d "${RLIBS}" ]; then echo "R library path ${RLIBS} already exists. Please remove it or choose a new prefix with --prefix"; exit 1; fi

# Check paths of install scripts
SHFILE="install_nci.submit.sh"
RFILE="install.R"
if [ ! -f "${SHFILE}" ] && [ ! -f "${RFILE}" ]
then
    SHFILE="install/${SHFILE}"
    RFILE="install/${RFILE}"
fi
if [ ! -f "${SHFILE}" ] && [ ! -f "${RFILE}" ]; then echo "Error: Cannot find install scripts install_nci.submit.sh and install.R. Exiting."; exit 1; fi


# Print R_LIBS_USER path and instructions
echo -e "R libraries will be installed to the following path:\n"
echo -e "${RLIBS}\n"
echo -e "When running the notebooks, you will need to set the R_LIBS_USER environment variable to this path:\n"
echo -e "R_LIBS_USER=${RLIBS}" | tee $(dirname ${SHFILE})/setenv.sh
echo -e ""

# Define qsub command
CMD="qsub -P ${PROJ} -l storage=gdata/${PROJ}+scratch/${PROJ} -v PREFIX='${PREFIX}' ${SHFILE}"

# If --submit was provided, submit the installation script
# Otherwise, perform a dry run
if ${SUBMIT}
then
    echo -e "Submitting the installation job to the cluster with the following command:\n"
    echo -e "${CMD}\n"
    eval $CMD
else
    echo -e "*** DRY RUN ONLY ***"
    echo -e "To submit the installation job to the cluster, run this script again with the --submit flag, or run the following command:\n"
    echo -e "${CMD}\n"
fi