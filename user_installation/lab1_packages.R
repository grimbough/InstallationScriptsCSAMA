source("http://192.168.0.9/biocLite.R")
pkgs <- c("AnnotationHub","BSgenome.Hsapiens.UCSC.hg19","BiocParallel","Biostrings","GenomicAlignments","GenomicFiles","GenomicRanges","Gviz","IRanges","RNAseqData.HNRNPC.bam.chr14","Rsamtools","TxDb.Hsapiens.UCSC.hg19.knownGene","VariantAnnotation","biomaRt","ggplot2","knitr","microbenchmark","org.Hs.eg.db","rtracklayer")
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}