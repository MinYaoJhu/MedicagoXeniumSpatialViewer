# app.R
library(shiny)
library(Seurat)
library(future)
library(ggplot2)

# Allow up to 500 MB upload
options(shiny.maxRequestSize = 1024 * 1024 * 500)

# Set multicore processing
plan("multisession", workers = 4)

# Source UI and server modules
source("modules/ui_main.R")
source("modules/server_main.R")

# Launch the app
shinyApp(ui = ui_main, server = server_main)
