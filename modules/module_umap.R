# modules/module_umap.R
umap_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("run_cluster"), "Run Clustering"),
    plotOutput(ns("umap_plot"))
  )
}

umap_server <- function(id, seurat_obj) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$run_cluster, {
      req(seurat_obj())
      obj <- seurat_obj()
      obj <- SCTransform(obj, assay = "Xenium")
      obj <- RunPCA(obj, npcs = 30)
      obj <- RunUMAP(obj, dims = 1:30)
      obj <- FindNeighbors(obj, dims = 1:30)
      obj <- FindClusters(obj, resolution = 0.3)
      seurat_obj(obj)
    })
    
    output$umap_plot <- renderPlot({
      req(seurat_obj())
      DimPlot(seurat_obj(), group.by = "seurat_clusters", label = TRUE)
    })
  })
}
