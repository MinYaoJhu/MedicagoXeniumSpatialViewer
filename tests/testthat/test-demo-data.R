test_that("demo dataset is a valid Xenium Seurat object", {
  expect_s4_class(demo, "Seurat")
  expect_equal(dim(demo), c(313, 12606))
  expect_true("Xenium" %in% Assays(demo))
  expect_equal(Images(demo), "fov")
  expect_true(all(c("nCount_Xenium", "nFeature_Xenium") %in% colnames(demo[[]])))
})

test_that("every demo cell has transcripts and a position", {
  expect_true(all(demo$nCount_Xenium > 0))
  coords <- GetTissueCoordinates(demo[["fov"]], which = "centroids")
  expect_equal(nrow(coords), ncol(demo))
})

test_that("demo file matches the documented build", {
  expect_lt(file.size(demo_path) / 1024^2, 5)
  readme <- readLines(file.path(app_dir, "data", "README.md"))
  expect_true(any(grepl("CC BY 4.0", readme)))
})
