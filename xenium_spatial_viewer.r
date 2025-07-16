-- app.R
library(shiny)
library(shinyWidgets)
library(Seurat)
library(ggplot2)
library(plotly)
library(DT)
library(patchwork)

source("modules/ui_main.R")
source("modules/server_main.R")

shinyApp(
  ui = ui_main(),
  server = server_main
)

-- modules/ui_main.R
ui_main <- function() {
  fluidPage(
    titlePanel("🧬 Xenium Spatial Viewer"),
    sidebarLayout(
      sidebarPanel(
        fileInput("rds_file", "Upload Seurat .rds Object", accept = ".rds"),
        pickerInput("color_by", "Color By:", choices = NULL),
        textInput("gene", "Gene Expression Viewer", value = ""),
        actionButton("refresh", "🔄 Refresh")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("UMAP", plotlyOutput("umap_plot")),
          tabPanel("Spatial", plotOutput("spatial_plot")),
          tabPanel("Gene Expression", plotlyOutput("gene_plot"))
        )
      )
    )
  )
}

-- modules/server_main.R
source("modules/module_umap.R")
source("modules/module_spatial.R")
source("modules/module_gene_expression.R")

server_main <- function(input, output, session) {
  rv <- reactiveValues(seurat = NULL)

  observeEvent(input$rds_file, {
    req(input$rds_file)
    rv$seurat <- readRDS(input$rds_file$datapath)
    updatePickerInput(session, "color_by", choices = c("seurat_clusters", colnames(rv$seurat@meta.data)))
  })

  module_umap_server("umap", rv)
  module_spatial_server("spatial", rv)
  module_gene_expression_server("gene", rv, reactive(input$gene))
}

-- modules/module_umap.R
module_umap_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$umap_plot <- renderPlotly({
      req(rv$seurat)
      DimPlot(rv$seurat, reduction = "umap", group.by = input$color_by) + theme_minimal()
    })
  })
}

-- modules/module_spatial.R
module_spatial_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {
    output$spatial_plot <- renderPlot({
      req(rv$seurat)
      SpatialDimPlot(rv$seurat, group.by = input$color_by, stroke = 0.2)
    })
  })
}

-- modules/module_gene_expression.R
module_gene_expression_server <- function(id, rv, gene_reactive) {
  moduleServer(id, function(input, output, session) {
    output$gene_plot <- renderPlotly({
      req(rv$seurat, gene_reactive())
      FeaturePlot(rv$seurat, features = gene_reactive()) + theme_minimal()
    })
  })
}
