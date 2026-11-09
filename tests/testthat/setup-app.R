# Loaded once before the tests: source the app modules and read the demo data.
suppressPackageStartupMessages({
  library(shiny)
  library(Seurat)
  library(DT)
})

app_dir <- normalizePath(file.path(testthat::test_path(), "..", ".."))

for (f in list.files(file.path(app_dir, "modules"), pattern = "^module_.*\\.R$", full.names = TRUE)) source(f)
source(file.path(app_dir, "modules", "ui_main.R"))
source(file.path(app_dir, "modules", "server_main.R"))

demo_path <- file.path(app_dir, DEMO_FILE)
demo <- readRDS(demo_path)

# Cluster the demo once and reuse it in tests that need clusters
clustered <- local({
  rv <- reactiveVal(demo)
  testServer(umap_server, args = list(seurat_obj = rv), session$setInputs(run_cluster = 1))
  isolate(rv())
})

# TRUE when a renderPlot output produced an image
plot_rendered <- function(x) is.list(x) && grepl("^data:image/png;base64,", x$src)
