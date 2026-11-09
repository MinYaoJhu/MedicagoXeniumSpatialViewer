# End-to-end test in headless Chrome: the real app loads the demo and draws plots.
test_that("app runs in a browser with the demo dataset", {
  skip_on_cran()
  skip_if_not_installed("shinytest2")
  skip_if(is.null(chromote::find_chrome()), "Chrome not available")

  app <- shinytest2::AppDriver$new(app_dir, name = "browser", load_timeout = 60 * 1000)
  on.exit(app$stop(), add = TRUE)

  app$click("load_demo", wait_ = FALSE)
  app$wait_for_js("document.querySelectorAll('#qc_mod-qc_violin img').length > 0",
                  timeout = 60 * 1000)

  app$set_inputs(tabs = "UMAP + Clustering", wait_ = FALSE)
  app$click("umap_mod-run_cluster", wait_ = FALSE)
  app$wait_for_js("document.querySelectorAll('#umap_mod-umap_plot img').length > 0",
                  timeout = 3 * 60 * 1000)

  expect_true(app$get_js("document.querySelector('#umap_mod-umap_plot img').naturalWidth > 0"))
})
