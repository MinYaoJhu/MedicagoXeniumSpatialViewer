# modules/server_main.R
DEMO_FILE <- "data/demo_xenium_breast.rds"

server_main <- function(input, output, session) {
  seurat_obj <- reactiveVal(NULL)

  load_object <- function(path, label) {
    obj <- withProgress(message = paste("Reading", label, "..."), readRDS(path))
    if (!inherits(obj, "Seurat")) {
      showNotification("The uploaded file is not a Seurat object.", type = "error")
      return()
    }
    seurat_obj(obj)

    # Server-side selectize keeps the UI responsive for large gene panels
    updateSelectizeInput(session, "gene_input", choices = rownames(obj), server = TRUE)
    showNotification(sprintf("Loaded %s: %d cells, %d genes", label, ncol(obj), nrow(obj)))
  }

  observeEvent(input$rds_file, {
    req(input$rds_file)
    load_object(input$rds_file$datapath, input$rds_file$name)
  })

  observeEvent(input$load_demo, {
    req(file.exists(DEMO_FILE))
    load_object(DEMO_FILE, "demo dataset")
  })

  # Call modules
  qc_server("qc_mod", seurat_obj)
  umap_server("umap_mod", seurat_obj)
  spatial_server("spatial_mod", seurat_obj)
  gene_expression_server("gene_mod", seurat_obj, reactive(input$gene_input))
  markers_server("markers_mod", seurat_obj)
}
