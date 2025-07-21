# modules/server_main.R
server_main <- function(input, output, session) {
  seurat_obj <- reactiveVal(NULL)
  
  observeEvent(input$rds_file, {
    req(input$rds_file)
    obj <- readRDS(input$rds_file$datapath)
    seurat_obj(obj)
    
    updateSelectInput(session, "gene_input", choices = rownames(obj))
  })
  
  output$gene_selector <- renderUI({
    req(seurat_obj())
    selectInput("gene_input", "Select Gene", choices = rownames(seurat_obj()))
  })
  
  # Call modules
  gene_expression_server("gene_mod", seurat_obj, reactive(input$gene_input))
  spatial_server("spatial_mod", seurat_obj)
  umap_server("umap_mod", seurat_obj)
  qc_server("qc_mod", seurat_obj)
}
