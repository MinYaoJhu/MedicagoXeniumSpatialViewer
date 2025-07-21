# modules/module_qc.R

qc_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h4("QC Violin Plot"),
    helpText("📌 nFeature_Xenium: Number of unique genes detected per cell."),
    helpText("📌 nCount_Xenium: Total transcript (UMI) count per cell."),
    helpText("Use these metrics to identify low-quality or overly complex cells."),
    
    checkboxGroupInput(
      ns("qc_features"),
      "Select QC Metrics to Plot:",
      choices = c("nFeature_Xenium", "nCount_Xenium"),
      selected = c("nFeature_Xenium", "nCount_Xenium")
    ),
    
    sliderInput(
      ns("pt_size"),
      "Point Size",
      min = 0, max = 2, value = 0.5, step = 0.1
    ),
    
    checkboxInput(
      ns("log_scale"),
      "Log-transform Y axis",
      value = FALSE
    ),
    
    plotOutput(ns("qc_violin"))
  )
}

qc_server <- function(id, seurat_obj) {
  moduleServer(id, function(input, output, session) {
    output$qc_violin <- renderPlot({
      req(seurat_obj(), input$qc_features)
      
      VlnPlot(
        object = seurat_obj(),
        features = input$qc_features,
        pt.size = input$pt_size,
        log = input$log_scale,
        ncol = 2
      )
    })
  })
}
