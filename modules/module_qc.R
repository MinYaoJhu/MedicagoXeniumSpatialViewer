# modules/module_qc.R

qc_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h4("QC Violin Plot"),
    helpText("📌 nFeature_*: Number of unique genes detected per cell."),
    helpText("📌 nCount_*: Total transcript count per cell."),
    helpText("Use these metrics to identify low-quality or overly complex cells."),

    checkboxGroupInput(ns("qc_features"), "Select QC Metrics to Plot:", choices = NULL),

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
    # Offer whichever nFeature_/nCount_ columns the object has (e.g. *_Xenium)
    observeEvent(seurat_obj(), {
      qc_cols <- grep("^n(Feature|Count)_", colnames(seurat_obj()[[]]), value = TRUE)
      updateCheckboxGroupInput(session, "qc_features", choices = qc_cols, selected = qc_cols)
    })

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
