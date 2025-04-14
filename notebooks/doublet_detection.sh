#!/bin/bash

set -euo pipefail

# Check input file exists
f="data/doublet_samples.csv"
if [ ! -f "$f" ]; then
  echo "Error: Input file '$f' not found."
  exit 1
fi

R --vanilla -e "rmarkdown::render('doublet_detection.qmd')"
