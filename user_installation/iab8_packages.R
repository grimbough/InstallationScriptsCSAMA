source("http://192.168.0.9/biocLite.R")
pkgs <- c("seqc","MLInterfaces","gridExtra","ggplot2")
pkgs <- pkgs[which( !pkgs %in% rownames(installed.packages()))]
if(length(pkgs)) {
    biocLite(pkgs)
} else {
    message("Nothing to be done.  All packages already installed.")
}