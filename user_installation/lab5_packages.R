source("http://192.168.0.9/biocLite.R")
pkgs <- c("MultiAssayExperiment","curatedMetagenomicData","ComplexHeatmap","survminer","yriMulti","gQTLstats","ldblock","DelayedArray","UpSetR","RaggedExperiment","TxDb.Hsapiens.UCSC.hg19.knownGene","org.Hs.eg.db","GenomeInfoDb")
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}
