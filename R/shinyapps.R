library(shiny)

# === QC ===

app_qc_thresholds <- function(all_metadata) {
  max_ncount <- max(all_metadata$nCount_RNA)
  max_nfeature <- max(all_metadata$nFeature_RNA)
  max_mt <- 100
  
  # make divisible by steps of 50
  max_ncount_adj <- round(max_ncount/50) * 50
  max_nfeature_adj <- round(max_nfeature/50) * 50
  
  shiny::shinyApp(
    ui = shiny::fluidPage(
      shiny::checkboxInput("log_x", "Display X-axis as log-scale?", value = TRUE),
      shiny::checkboxInput("log_y", "Display Y-axis as log-scale?", value = TRUE),
      
      shiny::sliderInput(
        "ncount",
        "nCount_RNA",
        min = 0,
        max = max_ncount_adj,
        value = c(0, max_ncount_adj),
        step = 50,
        ticks = FALSE,
        width = "80%"
      ),
      
      shiny::sliderInput(
        "nfeature",
        "nFeature_RNA",
        min = 0,
        max = max_nfeature_adj,
        value = c(0, max_nfeature_adj),
        step = 50,
        ticks = FALSE,
        width = "80%"
      ),
      
      shiny::sliderInput(
        "mt",
        "mt %",
        min = 0,
        max = max_mt,
        value = c(0, max_mt),
        step = 1,
        ticks = FALSE,
        width = "80%"
      ),
      
      shiny::plotOutput("plot")
    ),
    
    server = function(input, output) {
      output$plot <- shiny::renderPlot({
        p <- all_metadata %>%
          filter(nCount_RNA > input$ncount[1], nCount_RNA < input$ncount[2]) %>%
          filter(nFeature_RNA > input$nfeature[1], nFeature_RNA < input$nfeature[2]) %>%
          filter(percent.mt > input$mt[1], percent.mt < input$mt[2]) %>%
          ggplot(aes(x = nCount_RNA, y = nFeature_RNA, colour = percent.mt)) +
          geom_point(size = 0.25, alpha = 0.8) +
          scale_color_viridis_c() +
          facet_wrap(~ orig.ident) +
          theme_light()
        
        if (input$log_x) {
          p <- p + scale_x_log10()
        }
        if (input$log_y) {
          p <- p + scale_y_log10()
        }
        
        p
      })
    }
  )
}

# === Clustering ===

app_explore_clusters <- function(seurat_list, clustree_list, res) {
  seurat_obj_names <- names(seurat_list)
  res_named <- paste0("SCT_snn_res.", res)

  shinyApp(
    ui = fluidPage(
      
      selectInput(
        "selected_seurat",
        "Select Seurat object:",
        choices = seurat_obj_names
      ),
      
      plotOutput("p_clustree"),
      
      selectInput(
        "group_by",
        "Choose clustering resolution:",
        choices  = res_named, 
        selected = res_named[1] # lowest res by default
      ),
      
      plotOutput("p_clusters"),
      plotOutput("p_qc")
    ),
  
    server = function(input, output, session) {
  
      # Load object into app
      seurat_data <- reactive({
        req(input$selected_seurat) 
        seurat_list[[input$selected_seurat]]
      })
      
      output$p_clustree <- renderPlot({ clustree_list[[input$selected_seurat]] })
  
      output$p_clusters <- renderPlot({
        req(seurat_data())
        DimPlot(
          object = seurat_data(),
          reduction = "umap",
          group.by = input$group_by,
          label = TRUE
        )
      })
      
      output$p_qc <- renderPlot({
        req(seurat_data())
        meta <- seurat_data()@meta.data
        
        ggplot(meta, aes(x = nCount_RNA, y = nFeature_RNA, col = percent.mt)) +
          geom_point(size = 0.3) +
          facet_wrap(input$group_by) +
          scale_x_log10() +
          scale_y_log10() +
          theme_light() +
          viridis::scale_color_viridis() +
          annotation_logticks(side = "lb", colour = "lightgrey")
      })
    }
  )
}
