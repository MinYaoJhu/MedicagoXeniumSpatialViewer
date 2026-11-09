# Medicago Xenium Spatial Viewer <img src="assets/logo.svg" align="right" width="150" alt="MedicagoXeniumSpatialViewer logo"/>

**An interactive R Shiny app for exploring 10x Genomics Xenium *in situ* spatial transcriptomics data**

![R](https://img.shields.io/badge/R-%E2%89%A54.3-276DC3?logo=r&logoColor=white)
![Seurat](https://img.shields.io/badge/Seurat-v5-blue)
![Shiny](https://img.shields.io/badge/Shiny-app-blue?logo=rstudioide&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

`MedicagoXeniumSpatialViewer` lets you upload a Xenium Seurat object (`.rds`) and explore it in the browser: check cell quality, cluster cells, view clusters and gene expression on the tissue, and export marker genes. No R coding is needed after launch. It was built to explore *Medicago truncatula* root nodule Xenium data, and it works with any Xenium dataset loaded into Seurat.

## Features

| Tab | What it does |
|---|---|
| **QC Metrics** | Violin plots of genes and transcripts per cell (`nFeature_*`, `nCount_*`), with adjustable point size and log scale |
| **UMAP + Clustering** | One-click SCTransform → PCA → UMAP → graph-based clustering, with a progress bar |
| **Spatial Clustering** | Clusters mapped onto the tissue section coordinates |
| **Gene Expression** | Expression of any selected gene plotted on the tissue |
| **Marker Genes** | Marker genes for every cluster (`FindAllMarkers`), in a filterable table with CSV export |

## Workflow

<p align="center">
  <img src="assets/workflow.svg" width="100%" alt="Workflow: Xenium output is loaded with Seurat::LoadXenium(), saved as an .rds Seurat object, uploaded to the Shiny app for QC, clustering, spatial and gene views, and exported as plots and a marker gene table"/>
</p>

1. **Load** the Xenium output folder (transcripts, cell boundaries, cell-feature matrix) into Seurat with `LoadXenium()`.
2. **Save** the Seurat object as an `.rds` file.
3. **Explore** it in the app: QC, clustering and UMAP, clusters on the tissue, gene expression and marker genes.
4. **Export** plots and the marker gene table (`.csv`).

## 📂 Repository Structure

```
MedicagoXeniumSpatialViewer/
├── app.R                          # App launcher
├── modules/                       # Shiny modules (one per tab)
│   ├── ui_main.R                  # Page layout
│   ├── server_main.R              # Data loading and module wiring
│   ├── module_qc.R
│   ├── module_umap.R
│   ├── module_spatial.R
│   ├── module_gene_expression.R
│   └── module_markers.R
├── assets/
│   ├── logo.svg                   # Hex logo
│   ├── workflow.svg               # Workflow figure
│   ├── make_logo.py               # Reproducible figure generators
│   └── make_workflow.py
├── vignette.Rmd                   # Step-by-step tutorial
├── CITATION.cff
└── LICENSE
```

## Getting Started

### 1️⃣ Install required packages

```r
install.packages(c("shiny", "Seurat", "ggplot2", "DT"))
```

R ≥ 4.3 and Seurat v5 are recommended. SCTransform runs faster with the optional `glmGamPoi` package:

```r
BiocManager::install("glmGamPoi")
```

### 2️⃣ Launch the app

```r
shiny::runApp("path/to/MedicagoXeniumSpatialViewer")
```

### 3️⃣ Prepare your input

The app expects a Seurat object saved with `saveRDS()` that contains:

- an assay of Xenium counts (for example, created with `Seurat::LoadXenium()`)
- a spatial field of view (FOV), needed for the tissue plots
- optionally, existing `umap` and `seurat_clusters`; otherwise compute them in the **UMAP + Clustering** tab

```r
xenium_obj <- Seurat::LoadXenium("path/to/xenium_output_folder", fov = "fov")
saveRDS(xenium_obj, "xenium_obj.rds")
```

Uploads up to 5 GB are supported.

## 🗺️ Roadmap

- [ ] Demo dataset (a subset of a public 10x Genomics Xenium dataset) for a 30-second test run
- [ ] Interactive UMAP (plotly) and "color by" any metadata column
- [ ] Gene expression on UMAP alongside the tissue view
- [ ] PNG/PDF export of all plots
- [ ] Reproducible environment (`renv`) and automated tests

## Related Repositories

- [Medicago_Rhizobia_Xenium_Analysis_Workflow](https://github.com/MinYaoJhu/Medicago_Rhizobia_Xenium_Analysis_Workflow): the full analysis pipeline for the Medicago Xenium study
- [Medicago_Xenium_relabeling_resegmentation](https://github.com/MinYaoJhu/Medicago_Xenium_relabeling_resegmentation): transcript relabeling and cell segmentation
- [Xenium_data_analysis_training](https://github.com/MinYaoJhu/Xenium_data_analysis_training): a 4-week training course on Xenium data analysis

## Citation

If you use this app in your research, please cite it with the **"Cite this repository"** button on GitHub (generated from [`CITATION.cff`](CITATION.cff)), or as:

> Jhu, M.-Y. *MedicagoXeniumSpatialViewer: an interactive Shiny app for Xenium spatial transcriptomics.* GitHub repository, https://github.com/MinYaoJhu/MedicagoXeniumSpatialViewer

## 📧 Contact

Maintainer: **Min-Yao Jhu**, Donald Danforth Plant Science Center
Email: [MJhu@danforthcenter.org](mailto:MJhu@danforthcenter.org)
Questions and bug reports are welcome as [GitHub Issues](https://github.com/MinYaoJhu/MedicagoXeniumSpatialViewer/issues).
