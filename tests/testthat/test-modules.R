test_that("QC tab plots the available QC columns", {
  testServer(qc_server, args = list(seurat_obj = reactiveVal(demo)), {
    session$setInputs(qc_features = c("nFeature_Xenium", "nCount_Xenium"),
                      pt_size = 0, log_scale = TRUE)
    expect_true(plot_rendered(output$qc_violin))
  })
})

test_that("UMAP tab asks for clustering first, then clusters the data", {
  testServer(umap_server, args = list(seurat_obj = reactiveVal(demo)), {
    expect_error(output$umap_plot, "Run Clustering")
  })
  expect_true("umap" %in% Reductions(clustered))
  expect_gt(nlevels(clustered$seurat_clusters), 5)
  expect_equal(DefaultAssay(clustered), "SCT")
})

test_that("spatial tab needs clusters, then maps them on the tissue", {
  testServer(spatial_server, args = list(seurat_obj = reactiveVal(demo)), {
    expect_error(output$spatial_plot, "No clusters found")
  })
  testServer(spatial_server, args = list(seurat_obj = reactiveVal(clustered)), {
    expect_true(plot_rendered(output$spatial_plot))
  })
})

test_that("gene expression tab plots a selected gene", {
  gene <- reactiveVal("")
  testServer(gene_expression_server,
             args = list(seurat_obj = reactiveVal(demo), gene_input = gene), {
    expect_error(output$gene_plot, "Select a gene")
    gene("ERBB2")
    session$flushReact()
    expect_true(plot_rendered(output$gene_plot))
  })
})

test_that("marker genes are found and exported as CSV", {
  testServer(markers_server, args = list(seurat_obj = reactiveVal(clustered)), {
    session$setInputs(run_markers = 1)
    m <- markers()
    expect_true(all(c("gene", "cluster", "avg_log2FC", "p_val_adj") %in% colnames(m)))
    expect_true(all(m$avg_log2FC > 0))  # only.pos = TRUE

    csv <- read.csv(output$download_markers)
    expect_equal(nrow(csv), nrow(m))
  })
})

test_that("main server loads the demo dataset", {
  withr::with_dir(app_dir, {
    testServer(server_main, {
      expect_null(seurat_obj())
      session$setInputs(load_demo = 1)
      expect_equal(ncol(seurat_obj()), 12606)
    })
  })
})
