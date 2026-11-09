# app.R
library(shiny)
library(Seurat)
library(ggplot2)
library(DT)

# Xenium Seurat objects are often several GB; allow uploads up to 5 GB
options(shiny.maxRequestSize = 5 * 1024^3)

# Source modules, then the main UI and server
for (f in list.files("modules", pattern = "^module_.*\\.R$", full.names = TRUE)) source(f)
source("modules/ui_main.R")
source("modules/server_main.R")

# Launch the app
shinyApp(ui = ui_main, server = server_main)
