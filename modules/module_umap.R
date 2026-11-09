# modules/module_umap.R
umap_ui <- function(id) {
  ns <- NS(id)
  tagList(
    helpText("Runs SCTransform, PCA (30 PCs), UMAP and Louvain clustering (resolution 0.3)."),
    actionButton(ns("run_cluster"), "Run Clustering"),
    plotOutput(ns("umap_plot"))
  )
}

umap_server <- function(id, seurat_obj) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$run_cluster, {
      req(seurat_obj())
      obj <- seurat_obj()
      assay <- if ("Xenium" %in% Assays(obj)) "Xenium" else DefaultAssay(obj)

      withProgress(message = "Clustering", value = 0, {
        incProgress(0.1, detail = "SCTransform")
        obj <- SCTransform(obj, assay = assay)
        incProgress(0.4, detail = "PCA")
        obj <- RunPCA(obj, npcs = 30)
        incProgress(0.2, detail = "UMAP")
        obj <- RunUMAP(obj, dims = 1:30)
        incProgress(0.2, detail = "Finding clusters")
        obj <- FindNeighbors(obj, dims = 1:30)
        obj <- FindClusters(obj, resolution = 0.3)
      })
      seurat_obj(obj)
    })

    output$umap_plot <- renderPlot({
      req(seurat_obj())
      validate(need(
        "umap" %in% Reductions(seurat_obj()),
        "No UMAP found in this object. Click 'Run Clustering' to compute one."
      ))
      DimPlot(seurat_obj(), reduction = "umap", label = TRUE)
    })
  })
}
