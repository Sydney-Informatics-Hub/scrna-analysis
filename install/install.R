#!/usr/bin/env -S Rscript --vanilla

# Install all required packages
install.packages(
  c(
    "here",
    "devtools",
    "tidyverse",
    "Seurat",
    "hdf5r",
    "clustree",
    "DT",
    "shiny",
    "ggplot2",
    "ggrepel",
    "WebGestaltR",
    "BiocManager",
    "remotes",
    "htmltools"
  ),
  repos = "https://cran.csiro.au/"
)
remotes::install_github("chris-mcginnis-ucsf/DoubletFinder")
remotes::install_github("immunogenomics/presto")
remotes::install_github("bnprks/BPCells/r")
BiocManager::install(
  c(
    "SingleCellExperiment",
    "SingleR",
    "celldex",
    "glmGamPoi",
    "scuttle",
    "DESeq2",
    "EnsDb.Hsapiens.v86"
  ),
  site_repository = "https://cran.csiro.au/",
  ask = FALSE
)