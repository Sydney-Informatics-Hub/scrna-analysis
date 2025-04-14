#!/bin/bash

set -euo pipefail

# Check all input files exist
for f in data/{samplesheet.csv,cluster_filter.tsv,cluster_resolutions.tsv}
do
  if [ ! -f "$f" ]; then
    echo "Error: Input file '$f' not found."
    exit 1
  fi
done

R --vanilla -e "rmarkdown::render('qc.qmd')"
