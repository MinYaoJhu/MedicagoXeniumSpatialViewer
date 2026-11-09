# modules/server_main.R
server_main <- function(input, output, session) {
  seurat_obj <- reactiveVal(NULL)

  observeEvent(input$rds_file, {
    req(input$rds_file)
    obj <- withProgress(message = "Reading Seurat object...", readRDS(input$rds_file$datapath))
    if (!inherits(obj, "Seurat")) {
      showNotification("The uploaded file is not a Seurat object.", type = "error")
      return()
    }
    seurat_obj(obj)

    # Server-side selectize keeps the UI responsive for large gene panels
    updateSelectizeInput(session, "gene_input", choices = rownames(obj), server = TRUE)
  })

  # Call modules
  qc_server("qc_mod", seurat_obj)
  umap_server("umap_mod", seurat_obj)
  spatial_server("spatial_mod", seurat_obj)
  gene_expression_server("gene_mod", seurat_obj, reactive(input$gene_input))
  markers_server("markers_mod", seurat_obj)
}
