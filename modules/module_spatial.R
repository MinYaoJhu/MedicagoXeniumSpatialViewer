# modules/module_spatial.R
spatial_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("spatial_plot"))
  )
}

spatial_server <- function(id, seurat_obj) {
  moduleServer(id, function(input, output, session) {
    output$spatial_plot <- renderPlot({
      req(seurat_obj())
      validate(
        need(length(Images(seurat_obj())) > 0, "This object has no spatial (FOV) image."),
        need(
          "seurat_clusters" %in% colnames(seurat_obj()[[]]),
          "No clusters found. Run clustering in the 'UMAP + Clustering' tab first."
        )
      )
      ImageDimPlot(
        seurat_obj(),
        group.by = "seurat_clusters",
        axes = TRUE,
        coord.fixed = TRUE,
        size = 3
      )
    })
  })
}
