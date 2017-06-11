source("http://192.168.0.9/biocLite.R")
pkgs_charlotte <- c("rmarkdown","BiocStyle","knitr","airway","Rsamtools","GenomicFeatures","GenomicAlignments","BiocParallel","magrittr","DESeq2","vsn","dplyr","ggplot2","pheatmap","RColorBrewer","PoiClaClu","ggbeeswarm","genefilter","AnnotationDbi","org.Hs.eg.db","ReportingTools","Gviz","sva","fission","tximport","tximportData","edgeR","Homo.sapiens","Glimma","topGO","Rsubread")
pkgs_wolfgang <- c("rnaseqGene")
pkgs <- unique(c(pkgs_charlotte, pkgs_wolfgang))
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}

