# Single Cell RNA Sequencing Analysis

A series of R notebooks for analysing single cell RNA sequencing data.

## Introduction

This collection of R notebooks has been designed to guide you through processing and analysing your single cell RNA (scRNA) sequencing data. They are designed to be worked through in order, from quality control, doublet detection, dataset integration, and differential gene expression and pathway enrichment analyses. Each notebook explains what is happening in each step, complete with code and rationales for the choices we have made in our approach.

It is important to note there is no one single way to pre-process scRNA data - there are as many ways as there are different software packages and libraries for scRNA analysis, and the limitless ways to use each of their tools and functions.

The workflow presented in these notebooks is the synthesis of best practices, studies, and discussions of how to analyse scRNA data with a focus on using Seurat in R. Footnotes and external links accompany the text throughout the document - please view these for useful additional information and rationale on why steps are done in certain ways.

This content primarily uses the Seurat R package, but the way and order things are run differs vastly from their tutorials. We like to note that the Satija lab Seurat tutorials are instructions on how to use the package, but not how to conduct robust scRNA pre-processing and analysis. This content leverages the flexibility of the Seurat package, but is supplemented by the practices outlined in existing resources. These resources are the most influential:

-   [Current best practices in single-cell RNA-seq analysis: a tutorial (Luecken and Theis, 2019)](https://www.embopress.org/doi/full/10.15252/msb.20188746)
-   [scRNAseq analysis in R with Seurat (Williams and Perlaza, 2024)](https://swbioinf.github.io/scRNAseqInR_Doco/)
-   [Spatial Sampler (Williams, 2025)](https://swbioinf.github.io/spatialsnippets/)

## How to use the Quarto notebooks

The notebooks are written in the Quarto format - a format very closely related to R markdown. This format allows code to be interspersed with human-friendly text that explains what we are doing at each step. It also allows you to generate a styled HTML document at the end to save a record of the analyses you have run.

We recommend using [RStudio](https://posit.co/download/rstudio-desktop/) to run each notebook within the [notebooks/](notebooks/) directory.

Each chunk must be run sequentially. This ensures reproducibility and that objects saved in your R environment do not get mixed up.

At the end of each notebook, we also recomment restarting your R session to clear large objects from the workspace.

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
