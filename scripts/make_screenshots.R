# scripts/make_screenshots.R
#
# Regenerate the README screenshots (assets/screenshots/*.png) by driving the
# app in headless Chrome with shinytest2, using the bundled demo dataset.
#
# Usage (from the repository root):
#   Rscript scripts/make_screenshots.R

library(shinytest2)
Sys.setenv(NOT_CRAN = "true")  # AppDriver skips itself otherwise

out_dir <- "assets/screenshots"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

app <- AppDriver$new(".", name = "screenshots", width = 1400, height = 950,
                     load_timeout = 60 * 1000, timeout = 5 * 60 * 1000)

# Wait until an element appears on the page; more reliable than
# wait_for_idle(), which can stall until its timeout on this app.
wait_for <- function(css) {
  app$wait_for_js(sprintf("document.querySelectorAll('%s').length > 0", css))
  Sys.sleep(0.5)
}

# Full-app screenshot, or just the active tab's content when panel = TRUE
shot <- function(tab, file, css, panel = TRUE) {
  app$set_inputs(tabs = tab, wait_ = FALSE)
  wait_for(css)
  app$get_screenshot(file.path(out_dir, file),
                     selector = if (panel) "div.tab-content" else "html")
  message("saved ", file)
}

app$click("load_demo", wait_ = FALSE)
shot("QC Metrics", "panel_qc.png", "#qc_mod-qc_violin img")

app$set_inputs(tabs = "UMAP + Clustering", wait_ = FALSE)
app$click("umap_mod-run_cluster", wait_ = FALSE)
shot("UMAP + Clustering", "panel_umap.png", "#umap_mod-umap_plot img")

shot("Spatial Clustering", "app_overview.png", "#spatial_mod-spatial_plot img", panel = FALSE)

app$set_inputs(gene_input = "ERBB2", wait_ = FALSE)
shot("Gene Expression", "panel_gene_expression.png", "#gene_mod-gene_plot img")

app$set_inputs(tabs = "Marker Genes", wait_ = FALSE)
app$click("markers_mod-run_markers", wait_ = FALSE)
shot("Marker Genes", "panel_markers.png", "#markers_mod-marker_table tbody tr td")

app$stop()
