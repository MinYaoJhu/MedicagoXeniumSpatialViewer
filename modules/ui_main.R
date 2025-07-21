# modules/ui_main.R
source("modules/module_umap.R")
source("modules/module_spatial.R")
source("modules/module_gene_expression.R")
source("modules/module_qc.R")

ui_main <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  
  titlePanel("Xenium Spatial Transcriptome Viewer"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("rds_file", "Upload Xenium Seurat RDS", accept = ".rds"),
      hr(),
      uiOutput("gene_selector")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Gene Expression", gene_expression_ui("gene_mod")),
        tabPanel("Spatial Clustering", spatial_ui("spatial_mod")),
        tabPanel("UMAP + Clustering", umap_ui("umap_mod")),
        tabPanel("QC Metrics", qc_ui("qc_mod"))
      )
    )
  )
)
