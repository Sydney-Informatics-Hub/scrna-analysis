#!/usr/bin/env -S Rscript --vanilla

# Try loading all required packages
tryCatch(
    {
        library("here")
        library("devtools")
        library("tidyverse")
        library("Seurat")
        library("hdf5r")
        library("clustree")
        library("DT")
        library("shiny")
        library("ggplot2")
        library("ggrepel")
        library("WebGestaltR")
        library("BiocManager")
        library("remotes")
        library("chris-mcginnis-ucsf/DoubletFinder")
        library("immunogenomics/presto")
        library("bnprks/BPCells/r")
        library("SingleCellExperiment")
        library("SingleR")
        library("celldex")
        library("glmGamPoi")
        library("scuttle")
        library("DESeq2")
        library("EnsDb.Hsapiens.v86")

        cat("\n\n=== REQUIRED PACKAGES WERE SUCCESSFULLY INSTALLED ===\n\n")
    },
    error = function(x) {
        cat("\n\n=== REQUIRED PACKAGES FAILED TO INSTALL CORRECTLY ===\n\n")
    }
)
