# Helper functions for scRNA analysis
library(Seurat)

# === QC ===

readRDS_update_metadata <- function(path_to_rds, sample_name, mt_pattern = "^MT-", metadata = NULL) {
  # Read RDS, add metadata if requested
  so <- readRDS(path_to_rds)
  # Ensure sample names are assigned for plotting
  so@project.name <- sample_name
  so$orig.ident <- as.factor(sample_name)
  # Add MT percentage (optional)
  if (!is.null(mt_pattern)) {
    # Check if using gene names or accession IDs
    if (!all(rownames(so@assays$RNA) == so@assays$RNA@meta.data$gene_symbols)) {
      rn <- rownames(so@assays$RNA)
      rownames(so@assays$RNA) <- so@assays$RNA@meta.data$gene_symbols
      so$percent.mt <- Seurat::PercentageFeatureSet(so, pattern = "^MT-")
      rownames(so@assays$RNA) <- rn
    } else {
      so$percent.mt <- Seurat::PercentageFeatureSet(so, pattern = "^MT-")
    }
  } else {
    so$percent.mt <- 0  # NOTE: Setting default to 0 for now so it works with downstream code that expects percent.mt
  }
  # Add additional metadata (optional)
  if (!is.null(metadata)) {
    for (md in names(metadata)) {
      so[[md]] = metadata[[md]]
    }
  }
  return(so)
}

get_metadata_df <- function(all_seurats) {
  # combines all metadata cols across prepare it for plotting compatibility with ggplot
  lapply(all_seurats, function(seurat_obj) {
    seurat_obj@meta.data %>%
      rownames_to_column(var = "barcode")
  }) %>%
    bind_rows()
}

plot_filtered <- function(all_metadata, qc_list, filtered = FALSE) {
  # Plots static image of QC with metadata thresholds
  if (filtered) {
    all_metadata %>%
      filter(nCount_RNA < qc_list$ncount_upper & nCount_RNA > qc_list$ncount_lower) %>%
      filter(nFeature_RNA < qc_list$nfeature_upper & nFeature_RNA > qc_list$nfeature_lower) %>%
      filter(percent.mt < qc_list$mtpercent_upper)
    
    title <- "After Filtering"
  } else {
    title <- "Before Filtering"
  }
  all_metadata %>%
    ggplot(aes(x = nCount_RNA, y = nFeature_RNA, colour = percent.mt)) +
    geom_point(size = 0.1) +
    scale_color_viridis_c() +
    facet_wrap(~ orig.ident) +
    scale_x_log10() +
    scale_y_log10() +
    theme_light() +
    annotation_logticks(colour = "lightgrey") +
    ggtitle(title)
}

add_threshold_metadata <- function(seurat_object, qc_list_hard, qc_list_soft) {
  # Update the meta.data with new QC columns
  meta <- seurat_object@meta.data %>%
    mutate(
      qc_hard = case_when(
        percent.mt < qc_list_hard$mtpercent_upper &
          nFeature_RNA > qc_list_hard$nfeature_lower &
          nCount_RNA > qc_list_hard$ncount_lower &
          nCount_RNA < qc_list_hard$ncount_upper ~ "keep",
        TRUE ~ "remove"
      ),
      qc_soft = case_when(
        percent.mt < qc_list_soft$mtpercent_upper &
          nFeature_RNA > qc_list_soft$nfeature_lower &
          nCount_RNA > qc_list_soft$ncount_lower &
          nCount_RNA < qc_list_soft$ncount_upper ~ "keep",
        TRUE ~ "remove"
      )
    )
  seurat_object@meta.data <- meta
  return(seurat_object)
}

# === scTransform and dimension reduction ===

#' Find significant PCs
#'
#' From https://biostatsquid.com/doubletfinder-tutorial/.
#' Use this function to determine the number of PCs to include in downstream
#' analyses (i.e. other reductions (UMAP, tSNE), clustering). Requires a
#' `SeuratObject` that has a PCA reduction from `Seurat::RunPCA()`.
#'
#'
#' @param stdvs
#'
#' @examples
#' #find_min_pc(seurat_object@reductions$pca@stdev)
#'
find_min_pc <- function(stdvs) {
  percent_stdv <- (stdvs/sum(stdvs)) * 100
  cumulative <- cumsum(percent_stdv)
  co1 <- which(cumulative > 90 & percent_stdv < 5)[1]
  co2 <- sort(which((percent_stdv[1:length(percent_stdv) - 1] -
                       percent_stdv[2:length(percent_stdv)]) > 0.1),
              decreasing = T)[1] + 1
  min_pc <- min(co1, co2)
  print(min_pc)
}

SCTransform_reduce_dims <- function(so) {
  # Normalise with SCTransform and reduce dimensions with PCA.
  sct <-
    Seurat::SCTransform(so, vars.to.regress = c("percent.mt"), verbose = F) |>
    Seurat::RunPCA()

  # Calculate the minimum number of PCs that explain the majority of the variation
  min_pc <- find_min_pc(sct@reductions$pca@stdev)

  sct <-
    Seurat::RunUMAP(sct, dims = 1:min_pc, verbose = F) |>
    Seurat::FindNeighbors(dims = 1:min_pc, verbose = F)

  return(sct)
}
