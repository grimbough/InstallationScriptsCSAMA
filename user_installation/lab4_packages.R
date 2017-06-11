source("http://192.168.0.9/biocLite.R")
pkgs_johannes <- c("BiocStyle","xcms","faahKO","RColorBrewer","doParallel","XML","Rgraphviz","plyr","RANN","multtest","MassSpecWavelet","mzR","ProtGenerics","MSnbase","ensembldb","EnsDb.Hsapiens.v75","EnsDb.Hsapiens.v86")
pkgs_laurent <- c("ggplot2","gridExtra","dplyr","msdata","mzR","MSnbase","msmsTests","msmsEDA","pRolocdata","pRoloc","MSnID","MSGFplus","MSGFgui","RforProteomics","rpx","rols","hpar","qvalue","multtest")
pkgs <- unique(c(pkgs_johannes, pkgs_laurent))
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}
