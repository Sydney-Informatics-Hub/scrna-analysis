#!/usr/bin/env -S Rscript --vanilla

# Install all required packages
install.packages(c(
  "here",
  "tidyverse",
  "Seurat",
  "hdf5r",
  "clustree",
  "DT",
  "shiny",
  "ggplot2",
  "ggrepel",
  "WebGestaltR"
))
remotes::install_github("chris-mcginnis-ucsf/DoubletFinder")
BiocManager::install(
  c(
    "SingleCellExperiment",
    "SingleR",
    "celldex",
    "glmGamPoi",
    "scuttle",
    "DESeq2"
  ),
  ask = FALSE
)