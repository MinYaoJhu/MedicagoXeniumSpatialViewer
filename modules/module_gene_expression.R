# modules/module_gene_expression.R
gene_expression_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("gene_plot"))
  )
}

gene_expression_server <- function(id, seurat_obj, gene_input) {
  moduleServer(id, function(input, output, session) {
    output$gene_plot <- renderPlot({
      req(seurat_obj(), gene_input())
      ImageFeaturePlot(
        seurat_obj(),
        features = gene_input(),
        max.cutoff = "q90",
        size = 2,
        cols = c("white", "red")
      )
    })
  })
}
