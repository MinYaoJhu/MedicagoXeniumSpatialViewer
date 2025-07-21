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
