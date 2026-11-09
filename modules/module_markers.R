# modules/module_markers.R
markers_ui <- function(id) {
  ns <- NS(id)
  tagList(
    helpText("Finds positive marker genes for every cluster (Seurat::FindAllMarkers)."),
    actionButton(ns("run_markers"), "Find Marker Genes"),
    downloadButton(ns("download_markers"), "Download CSV"),
    hr(),
    DTOutput(ns("marker_table"))
  )
}

markers_server <- function(id, seurat_obj) {
  moduleServer(id, function(input, output, session) {
    markers <- reactiveVal(NULL)

    # Clear stale results when a new object is loaded or re-clustered
    observeEvent(seurat_obj(), markers(NULL))

    observeEvent(input$run_markers, {
      req(seurat_obj())
      if (!"seurat_clusters" %in% colnames(seurat_obj()[[]])) {
        showNotification("Run clustering in the 'UMAP + Clustering' tab first.", type = "warning")
        return()
      }
      res <- withProgress(
        message = "Finding marker genes...",
        FindAllMarkers(seurat_obj(), only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
      )
      markers(res)
    })

    output$marker_table <- renderDT({
      req(markers())
      num_cols <- c("p_val", "avg_log2FC", "pct.1", "pct.2", "p_val_adj")
      datatable(markers(), rownames = FALSE, filter = "top", options = list(pageLength = 15)) |>
        formatSignif(num_cols, digits = 3)
    })

    output$download_markers <- downloadHandler(
      filename = function() paste0("marker_genes_", Sys.Date(), ".csv"),
      content = function(file) {
        req(markers())
        write.csv(markers(), file, row.names = FALSE)
      }
    )
  })
}
