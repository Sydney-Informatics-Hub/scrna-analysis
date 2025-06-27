# Single Cell RNA Sequencing Analysis

A series of R notebooks for analysing single cell RNA sequencing data.

## Contents

- [Introduction](#introduction)
- [Workflow structure](#workflow-structure)
    - [Input data](#input-data)
    - [Quality control](#quality-control)
    - [Dataset integration](#dataset-integration)
    - [Analysis](#analysis)
- [How to use the Quarto notebooks](#how-to-use-the-quarto-notebooks)
    - [Platform](#platform)
    - [Rendering documents](#rendering-documents)

## Introduction

This collection of R notebooks has been designed to guide you through processing and analysing your single cell RNA (scRNA) sequencing data. They are designed to be worked through in the following order:

1. Quality control
2. Doublet detection
3. Dataset integration
4. Differential gene expression and pathway enrichment analyses.

Each notebook explains what is happening in each step, complete with code and rationales for the choices we have made in our approach.

It is important to note there is no one single way to pre-process scRNA data - there are as many ways as there are different software packages and libraries for scRNA analysis, and the limitless ways to use each of their tools and functions.

The workflow presented in these notebooks is the synthesis of best practices, studies, and discussions of how to analyse scRNA data with a focus on using Seurat in R. Footnotes and external links accompany the text throughout the document - please view these for useful additional information and rationale on why steps are done in certain ways.

This content primarily uses the Seurat R package, but the way and order things are run differs vastly from their tutorials. We like to note that the Satija lab Seurat tutorials are instructions on how to use the package, but not how to conduct robust scRNA pre-processing and analysis. This content leverages the flexibility of the Seurat package, but is supplemented by the practices outlined in existing resources. These resources are the most influential:

-   [Current best practices in single-cell RNA-seq analysis: a tutorial (Luecken and Theis, 2019)](https://www.embopress.org/doi/full/10.15252/msb.20188746)
-   [scRNAseq analysis in R with Seurat (Williams and Perlaza, 2024)](https://swbioinf.github.io/scRNAseqInR_Doco/)
-   [Spatial Sampler (Williams, 2025)](https://swbioinf.github.io/spatialsnippets/)

## Workflow structure

The workflow is split into four sections: quality control, doublet detection, dataset integration, and analysis:

![scRNA-seq workflow overview](img/workflow_overview.png)

### Input data

This workflow has been designed to be run after initial pre-processing with the [`nf-core/scrnaseq`](https://github.com/nf-core/scrnaseq/) Nextflow pipeline. That pipeline takes the raw sequencing data and performs genome alignment and counting of reads/UMIs per gene and per cell. The output of the `nf-core/scrnaseq` pipeline is one R data file (`.Rds`) per sample containing a Seurat data object that holds the sample's count matrix and related metadata. Your data must be in this format to begin working through these notebooks.

### Quality control

The first notebook in this workflow takes the input `.Rds` files containing your pre-processed Seurat data - one file per sample - and performs some basic quality control analyses to detect and remove low quality cells. This is an interactive process where you will be required to select thresholds for filtering. The notebook includes some interactive plots and figures to help guide your decisions in this process. We also perform initial normalisation and transformation of your count data to account for library size differences between samples.

The output from this first stage is a new series of `.Rds` files - again, one per sample - containing your filtered data.

### Doublet detection

The second notebook takes the output files from the quality control notebook and works through identifying doublets in your data. The cell capture process for single cell sequencing is not perfect and can result in multiple cells being captured together and given the same cellular barcode. This typically only affects a small proportion of the cell barcodes, and methods are available to detect these **doublet** and **multiplet** barcodes. In this notebook, we use the R library `DoubletFinder` for this purpose. By default, we remove these doublets from your data, as they will confound your results, although we give you the option of leaving them in and simply having them annotated as such.

The output from this stage is another series of `.Rds` files containing the doublet-free (or doublet-annotated) data - one file per sample.

### Dataset integration

The third notebook in this workflow takes the output of the doublet detection stage and performs dataset integration. This is a vital step that merges your data into a single object and helps to account for batch effects between samples. Without this step, you may find that cells will form clusters based solely on the sample they are from rather than by true biological differences. These batch effects will confound your analyses and make interpretation of results difficult or impossible.

In addition, this notebook works through a final round of data transformation and normalisation, followed by dimensionality reduction and cell clustering. These normalised data and clusters will be used in all downstream analyses.

The output from this stage is a single `.Rds` file containing the merged and integrated Seurat dataset. All downstream analyses will be performed on this single dataset.

### Analysis

The fourth notebook in this workflow takes the merged, integrated, and normalised data from the previous notebook and performs several analyses.

First, we annotate cells by cell cycle and cell type using public databases. We also provide you with an opportunity to supply curated marker gene lists for cell types that you are interested in, which we use to score and annotate your cells with.

After annotation, we perform pseudobulking, which sums together the counts from all cells within a cluster and treats the cluster like a single sample in a bulk RNA sequencing analysis. This has some important advantages, primarily allowing us to use existing bulk RNA sequencing tools and simpler, higher-powered statistical tests for analysing your data.

The pseudobulked data is then used to perform differential gene expression analysis and pathway enrichment analysis.

The outputs from this notebook are:

- An `.Rds` file containing your annotated single cell data
- An `.Rds` file containing your pseudobulked data
- A collection of web reports summarising the pathway enrichment analyses.

## How to use the Quarto notebooks

The notebooks are written in the Quarto format - a format very closely related to R markdown. This format allows code to be interspersed with human-friendly text that explains what we are doing at each step. It also allows you to generate a styled HTML document at the end to save a record of the analyses you have run.

We recommend using [RStudio](https://posit.co/download/rstudio-desktop/) to run each notebook within the [notebooks/](notebooks/) directory.

Each chunk must be run sequentially. This ensures reproducibility and that objects saved in your R environment do not get mixed up.

At the end of each notebook, we also recommend restarting your R session to clear large objects from the workspace.

Some chunks will require your input for setting parameters that will be unique to your data.

At other points, we will generate template files within the [inputs/](inputs/) directory that you will need to edit in order to proceed.

In both cases, the notebooks will highlight what is required.

### Platform

Single cell sequencing data is typically quite large, and processing more than a handful of samples can quickly require more computing resources than your typical laptop or desktop computer will have.

While these notebooks will work on your local computer, we have designed them with high-performance computing environments in mind. We recommend using a cloud- or HPC-hosted RStudio server to run these notebooks. We have tested the notebooks successfully on NCI's Australian Research Environment (ARE) - a web-based interface to the Gadi HPC, with the ability to run an RStudio server with the resources necessary to process large numbers of samples together.

As a consequence, we also only recommend running on Unix-like systems (e.g. Linux and Mac). These notebooks are untested on Windows and may not work as expected on that platform. Most HPC- and cloud-based environments are based on Linux and as such these notebooks will run well on these platforms.

### Rendering documents

Once you have run through all of the notebooks, you can render ("Knit") everything into a human-friendly HTML document. You can do this by running the following command in a terminal, within the top-level project directory:

```{bash}
quarto render
```

When rendering, the notebooks will avoid running expensive operations and will instead use the saved data objects created when running the notebooks interactively. This ensures that they render quickly and efficiently.
