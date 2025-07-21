# 🧬 XeniumSpatialViewer (Shiny App)

**Interactive R Shiny App for Exploring Spatial Transcriptomics from Xenium in situ**

`XeniumSpatialViewer` enables dynamic, web-based visualization of spatial gene expression across tissue sections using processed Seurat `.rds` objects from Xenium datasets. It complements your analysis workflow by providing an accessible interface to explore clusters, spatial localization, and gene expression interactively.

## 🚀 Features

- 🔍 **Load Preprocessed Seurat Objects**  
  Load preprocessed Xenium `Seurat` objects (`.rds`)
  QC visualization (UMI & gene count per cell)

- 🧭 **UMAP & Cluster Explorer**  
  View UMAPs with cluster IDs, organ types, developmental stages, etc.

- 🧫 **Tissue Spatial Viewer**  
  Overlay clusters or gene expression directly on the tissue image.

- 🧬 **Gene Expression Viewer**  
  Input a gene and visualize its expression on UMAP and tissue coordinates.

- 🧮 **Marker gene identification**  
  Marker gene identification and export.

- 💾 **Export & Snapshot**  
  Download plots as high-res PNG or PDF. Save gene expression tables.

## 📂 Repository Structure

```
XeniumSpatialViewer/
├── app.R                            # Main Shiny app launcher
├── modules/                         # Modularized UI and server logic
│   ├── ui_main.R
│   ├── server_main.R
│   ├── module_umap.R
│   ├── module_spatial.R
│   └── module_gene_expression.R
├── www/                             # CSS, images, logos
│   ├── style.css
│   └── logo.png
├── data/
│   └── example_data.rds             # Sample Seurat object
├── README.md
├── DESCRIPTION
├── LICENSE
└── .gitignore
```

## 🧑‍🔬 Getting Started

### 1️⃣ Install Required Packages

```r
install.packages(c("shiny", "shinyWidgets", "ggplot2", "plotly", "DT", "patchwork"))
BiocManager::install("Seurat")
```

### 2️⃣ Launch the App

```r
library(shiny)
runApp("path/to/XeniumSpatialViewer")
```

Or from within the repo folder:

```r
shiny::runApp()
```

## 🧪 Example Usage

Load your `.rds` Seurat object and:
- Explore clusters on UMAP
- Visualize marker genes on tissue
- Compare expression by condition (e.g. ecotype, DPI)
- Export plots for publication

## 🖼️ Screenshots

*Coming soon*

## 📜 Citation

If you use `XeniumSpatialViewer` in your research, please cite:

> Min-Yao, _XeniumSpatialViewer: Interactive Spatial Transcriptomics_, 2025. GitHub repository: [github.com/MinYaoJhu/XeniumSpatialViewer](https://github.com/yourname/XeniumSpatialViewer)

## 📧 Contact

Maintainer: **Min-Yao**  
Email: [myj23@cam.ac.uk](mailto:myj23@cam.ac.uk)

📅 Last updated: `r format(Sys.Date(), '%Y-%m-%d')`

---

## 📄 License

This project is licensed under the MIT License. See `LICENSE` for details.

---

Happy Spatial Mapping 🧬🧠🗺️
