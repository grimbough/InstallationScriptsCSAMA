source("http://192.168.0.9/biocLite.R")
pkgs <- c("IHW","rnaseqGene","xkcd","showtext","sysfonts","tibble","Hiiragi2013","dplyr","ggplot2","mouse4302.db","reshape2","Hmisc","ggbeeswarm","gridExtra","RColorBrewer","ggthemes","magrittr","plotly","rgl","pheatmap","colorspace","grid","ggbio","GenomicRanges","DESeq2","airway","fdrtool","readr","reshape2","MASS","GGally","gridExtra","ExperimentHub","glmnet","caret","kernlab")
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}