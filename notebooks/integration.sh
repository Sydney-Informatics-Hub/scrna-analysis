#!/bin/bash

set -euo pipefail

# Check all input files exist
for f in data/{integration_samples,integrated_cluster_resolution}.txt
do
  if [ ! -f "$f" ]; then
    echo "Error: Input file '$f' not found."
    exit 1
  fi
done

R --vanilla -e "rmarkdown::render('integration.qmd')"
