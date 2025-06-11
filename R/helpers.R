# Helper functions for scRNA analysis
library(Seurat)

# === QC ===

plot_filtered <- function(all_metadata, qc_list, filtered = FALSE) {
  # Plots static image of QC with metadata thresholds
  if (filtered) {
    tmp_all_metadata <- all_metadata %>%
      filter(nCount_RNA < qc_list$ncount_upper & nCount_RNA > qc_list$ncount_lower) %>%
      filter(nFeature_RNA < qc_list$nfeature_upper & nFeature_RNA > qc_list$nfeature_lower) %>%
      filter(percent.mt < qc_list$mtpercent_upper & percent.mt > qc_list$mtpercent_lower)
    
    title <- "After Filtering"
  } else {
    tmp_all_metadata <- all_metadata
    title <- "Before Filtering"
  }
  tmp_all_metadata %>%
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
