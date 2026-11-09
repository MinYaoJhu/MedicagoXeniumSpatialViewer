# modules/ui_main.R
ui_main <- fluidPage(
  titlePanel("Xenium Spatial Transcriptome Viewer"),

  sidebarLayout(
    sidebarPanel(
      fileInput("rds_file", "Upload Xenium Seurat RDS", accept = ".rds"),
      hr(),
      selectizeInput("gene_input", "Select Gene", choices = NULL)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("QC Metrics", qc_ui("qc_mod")),
        tabPanel("UMAP + Clustering", umap_ui("umap_mod")),
        tabPanel("Spatial Clustering", spatial_ui("spatial_mod")),
        tabPanel("Gene Expression", gene_expression_ui("gene_mod")),
        tabPanel("Marker Genes", markers_ui("markers_mod"))
      )
    )
  )
)
