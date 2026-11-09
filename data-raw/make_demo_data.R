# data-raw/make_demo_data.R
#
# Build the demo Seurat object (data/demo_xenium_breast.rds) from public
# 10x Genomics Xenium data: FFPE Human Breast Cancer, Replicate 1.
# See data/README.md for the source, citation and download details.
#
# Only three small output files are needed (~25 MB in total):
#   <prefix>_cell_feature_matrix.h5
#   <prefix>_cells.parquet
#   <prefix>_cell_boundaries.parquet
# from https://cf.10xgenomics.com/samples/xenium/1.0.1/Xenium_FFPE_Human_Breast_Cancer_Rep1/
#
# Usage (from the repository root):
#   Rscript data-raw/make_demo_data.R /path/to/Xenium_FFPE_Human_Breast_Cancer_Rep1

suppressPackageStartupMessages({
  library(Seurat)
  library(arrow)
})

args <- commandArgs(trailingOnly = TRUE)
data_dir <- if (length(args) >= 1) args[1] else "../public_demo_data/Xenium_FFPE_Human_Breast_Cancer_Rep1"
prefix <- "Xenium_FFPE_Human_Breast_Cancer_Rep1_"
in_file <- function(x) file.path(data_dir, paste0(prefix, x))

# Demo region: 1,600 x 1,600 um window with ductal structures and stroma
x_range <- c(1500, 3100)
y_range <- c(2500, 4100)

# ---- Read the Xenium outputs -------------------------------------------------
counts <- Read10X_h5(in_file("cell_feature_matrix.h5"))[["Gene Expression"]]
cells <- as.data.frame(read_parquet(in_file("cells.parquet")))
boundaries <- as.data.frame(read_parquet(in_file("cell_boundaries.parquet")))

cells$cell_id <- as.character(cells$cell_id)
boundaries$cell_id <- as.character(boundaries$cell_id)

# ---- Keep cells in the demo window that have transcripts --------------------
keep <- cells$cell_id[
  cells$x_centroid >= x_range[1] & cells$x_centroid < x_range[2] &
    cells$y_centroid >= y_range[1] & cells$y_centroid < y_range[2]
]
keep <- intersect(keep, colnames(counts)[Matrix::colSums(counts) > 0])

counts <- counts[, keep]
cells <- cells[match(keep, cells$cell_id), ]
boundaries <- boundaries[boundaries$cell_id %in% keep, ]

# ---- Build the Seurat object with the same layout as LoadXenium() -----------
obj <- CreateSeuratObject(counts = counts, assay = "Xenium")

centroids <- CreateCentroids(data.frame(
  x = cells$x_centroid, y = cells$y_centroid, cell = cells$cell_id
))
segmentation <- CreateSegmentation(data.frame(
  x = boundaries$vertex_x, y = boundaries$vertex_y, cell = boundaries$cell_id
))
fov <- CreateFOV(
  coords = list(centroids = centroids, segmentation = segmentation),
  type = c("segmentation", "centroids"),
  assay = "Xenium"
)
obj[["fov"]] <- fov

obj$cell_area <- cells$cell_area
obj$nucleus_area <- cells$nucleus_area

# ---- Save ---------------------------------------------------------------------
dir.create("data", showWarnings = FALSE)
out <- "data/demo_xenium_breast.rds"
saveRDS(obj, out, compress = "xz")

cat(sprintf("Saved %s: %d cells x %d genes, %.1f MB\n",
            out, ncol(obj), nrow(obj), file.size(out) / 1024^2))
sessionInfo()
