# Demo dataset

`demo_xenium_breast.rds` is a small Seurat object for trying the app. Click
**Load demo dataset** in the sidebar to use it.

> **Demo data only.** This is a public human breast cancer dataset from 10x
> Genomics, used to show how the app works. It will be replaced by our
> *Medicago truncatula* root nodule Xenium dataset once the associated paper is
> published.

## Contents

| | |
|---|---|
| Cells | 12,606 (one 1,600 × 1,600 µm region of the tissue section) |
| Genes | 313 (Xenium Human Breast panel, Gene Expression features only) |
| Region | `x_centroid` 1500–3100 µm, `y_centroid` 2500–4100 µm |
| Spatial data | cell centroids and cell segmentation boundaries (FOV `fov`) |
| Assay | `Xenium` (raw counts), same layout as `Seurat::LoadXenium()` |
| Size | 2.0 MB |

Control probe and blank codeword features, nucleus boundaries and individual
transcript locations are not included.

## Source

- **Dataset:** FFPE Human Breast using the Entire Sample Area, Replicate 1
  (`Xenium_FFPE_Human_Breast_Cancer_Rep1`), Xenium Onboard Analysis output v1.0.1,
  10x Genomics.
  Dataset page: <https://www.10xgenomics.com/datasets/ffpe-human-breast-using-the-entire-sample-area-1-standard>
- **License:** Creative Commons Attribution 4.0 International (CC BY 4.0), as stated by 10x Genomics for its public Xenium datasets.
- **Original article:** Janesick, A., Shelansky, R., et al.
  High resolution mapping of the tumor microenvironment using integrated
  single-cell, spatial and in situ analysis. *Nature Communications* 14, 8353 (2023).
  <https://doi.org/10.1038/s41467-023-43458-x>

## Download record

Files may be updated by 10x Genomics over time, so the exact files used are recorded here.

- **Downloaded:** 2026-11-09 (19:42 UTC)
- **Base URL:** `https://cf.10xgenomics.com/samples/xenium/1.0.1/Xenium_FFPE_Human_Breast_Cancer_Rep1/`

| File | Size (bytes) | MD5 |
|---|---|---|
| `Xenium_FFPE_Human_Breast_Cancer_Rep1_cell_feature_matrix.h5` | 12,148,885 | `3bfd29015fa8bacb821d9c9ee86bedaa` |
| `Xenium_FFPE_Human_Breast_Cancer_Rep1_cells.parquet` | 3,453,894 | `b545deb7a96141df76d19683bfb423db` |
| `Xenium_FFPE_Human_Breast_Cancer_Rep1_cell_boundaries.parquet` | 8,807,145 | `fa0120eea18bf01d756d4ea5c57dc9ea` |

## Rebuild

```bash
BASE=https://cf.10xgenomics.com/samples/xenium/1.0.1/Xenium_FFPE_Human_Breast_Cancer_Rep1/Xenium_FFPE_Human_Breast_Cancer_Rep1
mkdir -p demo_raw && cd demo_raw
for f in cell_feature_matrix.h5 cells.parquet cell_boundaries.parquet; do curl -O "${BASE}_${f}"; done
md5sum *   # compare with the table above
cd ..
Rscript data-raw/make_demo_data.R demo_raw
```
