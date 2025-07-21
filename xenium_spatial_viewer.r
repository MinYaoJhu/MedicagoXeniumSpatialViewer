library(shiny)
library(shinyWidgets)
library(Seurat)
library(ggplot2)
library(plotly)
library(DT)
library(patchwork)

# UI ----
ui <- fluidPage(
  titlePanel("Xenium Spatial Transcriptome Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("rds_file", "Upload Seurat RDS file", accept = ".rds"),
      hr(),
      selectInput("gene_input", "Choose gene", choices = NULL),
      actionButton("run_qc", "Show QC"),
      actionButton("run_gene", "Plot Gene Spatial"),
      hr(),
      actionButton("run_clustering", "Run Clustering"),
      downloadButton("download_markers", "Download Marker Genes")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", verbatimTextOutput("seurat_summary")),
        tabPanel("QC", plotOutput("qc_plot")),
        tabPanel("Gene Overlay", plotOutput("gene_plot")),
        tabPanel("UMAP", plotOutput("umap_plot")),
        tabPanel("Spatial Clusters", plotOutput("spatial_plot")),
        tabPanel("Markers", dataTableOutput("marker_table"))
      )
    )
  )
)

# SERVER ----
server <- function(input, output, session) {
  options(shiny.maxRequestSize = 1000 * 1024^2)  # allow large files
  
  seurat_obj <- reactiveVal(NULL)
  
  observeEvent(input$rds_file, {
    req(input$rds_file)
    obj <- readRDS(input$rds_file$datapath)
    seurat_obj(obj)
    
    updateSelectInput(session, "gene_input", choices = rownames(obj))
  })
  
  output$seurat_summary <- renderPrint({
    req(seurat_obj())
    seurat_obj()
  })
  
  output$qc_plot <- renderPlot({
    req(seurat_obj())
    VlnPlot(seurat_obj(), features = c("nFeature_Xenium", "nCount_Xenium"), pt.size = 0)
  })
  
  output$gene_plot <- renderPlot({
    req(seurat_obj(), input$gene_input)
    ImageFeaturePlot(
      seurat_obj(),
      features = input$gene_input,
      max.cutoff = "q90",
      size = 2,
      cols = c("white", "red")
    )
  })
  
  observeEvent(input$run_clustering, {
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
  
  output$spatial_plot <- renderPlot({
    req(seurat_obj())
    ImageDimPlot(seurat_obj(), group.by = "seurat_clusters", axes = TRUE, coord.fixed = TRUE)
  })
  
  markers <- reactiveVal(NULL)
  
  observeEvent(input$run_clustering, {
    req(seurat_obj())
    markers(FindAllMarkers(seurat_obj()))
  })
  
  output$marker_table <- renderDataTable({
    req(markers())
    datatable(markers())
  })
  
  output$download_markers <- downloadHandler(
    filename = function() { "AllMarkers.csv" },
    content = function(file) {
      write.csv(markers(), file, row.names = FALSE)
    }
  )
}

# RUN APP ----
shinyApp(ui = ui, server = server)
