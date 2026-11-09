# modules/module_gene_expression.R
gene_expression_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("gene_plot"), height = "650px")
  )
}

gene_expression_server <- function(id, seurat_obj, gene_input) {
  moduleServer(id, function(input, output, session) {
    output$gene_plot <- renderPlot({
      req(seurat_obj())
      validate(
        need(length(Images(seurat_obj())) > 0, "This object has no spatial (FOV) image."),
        need(isTruthy(gene_input()), "Select a gene in the sidebar.")
      )
      ImageFeaturePlot(
        seurat_obj(),
        features = gene_input(),
        max.cutoff = "q90",
        size = 1.2,
        cols = c("white", "red")
      )
    })
  })
}
