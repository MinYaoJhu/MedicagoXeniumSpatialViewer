# Run all tests from the repository root:
#   Rscript tests/testthat.R
Sys.setenv(NOT_CRAN = "true")  # also run the browser test
testthat::test_dir("tests/testthat", stop_on_failure = TRUE)
