##------------------------------------------------------------
## Installation script for CSAMA 2015
##------------------------------------------------------------

.required_R_version = "3.2.0"
.required_Bioc_version = "3.1"
.Bioc_devel_version = "3.2"

options(warn = 1)
.baseurl = "http://www-huber.embl.de"
.yr = format(Sys.Date(), "%y")

## Check memory size
pattern = "[0-9]+"
min_mem = 4
mem =
  switch(.Platform$OS.type,         
         unix = 
           if (file.exists("/proc/meminfo")) {
             ## regular linux
             res = system('grep "^MemTotal" /proc/meminfo', intern=TRUE)
             as.numeric(regmatches(res, regexpr(pattern, res)))/10^6
           } else {
             if (file.exists("/usr/sbin/system_profiler")) {
               ## try MAC os
               res = system('/usr/sbin/system_profiler SPHardwareDataType | grep "Memory"', intern=TRUE)
               as.numeric(regmatches(res, regexpr(pattern, res)))
             } else NULL  
           },
         windows = 
           tryCatch({
             res = system("wmic ComputerSystem get TotalPhysicalMemory", ignore.stderr=TRUE, intern=TRUE)[2L]
             as.numeric(regmatches(res, regexpr(pattern, res)))/10^9
           }, error = function(e) NULL),
         NULL)

if (is.null(mem)) {
  warning(sprintf("Could not determine the size of your system memory. Please make sure that your machine has at least %dGB of RAM!", min_mem))
} else {
  mem = round(mem)
  if ( mem < min_mem ) stop(sprintf("Found %dGB of RAM. You need a machine with at least %dGB of RAM for the CSAMA course!", mem, min_mem))
  else message(sprintf("Found %dGB of RAM", mem))
}

## Check the R version
R_version = paste(R.version$major, R.version$minor, sep=".")
if(R_version != .required_R_version && R_version != "3.2.1")
  stop(sprintf("You are using a version of R different than the one required for CSAMA'%s, please install R-%s", .yr, .required_R_version))

## Install Bioconductor
source("http://bioconductor.org/biocLite.R")
chooseBioCmirror()
chooseCRANmirror()

if( biocVersion() == .Bioc_devel_version )
  useDevel(devel = FALSE)

if( biocVersion() != .required_Bioc_version )
  stop(sprintf("Please install Bioconductor %s\n", .required_Bioc_version))

## Get list of packages to install
deps = c("abind", "acepack", "ade4", "affy", "airway", "annotate", "AnnotationDbi", "AnnotationHub", "ape", "assertthat", "BatchJobs", "BBmisc", "beeswarm", "BH", "Biobase", "BiocGenerics", "BiocInstaller", "BiocParallel", "BiocStyle", "biocViews", "biom", "biomaRt", "Biostrings", "biovizBase", "bitops", "boot", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "Category", "caTools", "checkmate", "chipseq", "class", "clue", "cluster", "colorspace", "data.table", "DBI", "deldir", "DESeq2", "devtools", "digest", "diptest", "doParallel", "dplyr", "DT", "EBImage", "edgeR", "EpigeneticsCSAMA2015", "evaluate", "extrafont", "ff", "ffbase", "fftwtools", "flexmix", "foreach", "foreign", "formatR", "Formula", "fpc", "futile.logger", "gam", "gdata", "genefilter", "geneplotter", "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicFiles", "GenomicRanges", "geometry", "geuvPack", "geuvStore", "GGally", "ggbio", "ggplot2", "ggthemes", "ggvis", "git2r", "glmnet", "GO.db", "goftest", "GOstats", "gplots", "gQTLBase", "gQTLstats", "graphics", "grDevices", "grid", "gridExtra", "GSEABase", "gtable", "gtools", "Gviz", "gwascat", "h5vc", "h5vcData", "hexbin", "highr", "Hiiragi2013", "Hmisc", "Homo.sapiens", "htmltools", "htmlwidgets", "httpuv", "httr", "hwriter", "igraph", "impute", "interactiveDisplay", "interactiveDisplayBase", "IRanges", "jpeg", "jsonlite", "KEGGREST", "kernlab", "KernSmooth", "knitr", "lattice", "latticeExtra", "lazyeval", "limma", "locfit", "LSD", "magic", "magrittr", "markdown", "MASS", "Matrix", "matrixStats", "mclust", "memoise", "metagenomeSeq", "methods", "mgcv", "microbenchmark", "mime", "mlr", "mouse4302.db", "MSBdata", "MSnbase", "multtest", "mvtnorm", "mzR", "nnet", "OrganismDbi", "org.Hs.eg.db", "parallel", "parallelMap", "ParamHelpers", "pasilla", "PFAM.db", "pheatmap", "phyloseq", "plyr", "png", "PoiClaClu", "polyclip", "prabclus", "proto", "PXD000001", "R6", "rafalib", "RColorBrewer", "Rcpp", "RcppArmadillo", "RCurl", "ReportingTools", "reshape", "reshape2", "RforProteomics", "rhdf5", "rmarkdown", "RNAseqData.HNRNPC.bam.chr14", "robustbase", "roxygen2", "rpart", "rpx", "Rsamtools", "RSQLite", "rstudioapi", "rtracklayer", "R.utils", "rversions", "S4Vectors", "scales", "shiny", "ShortRead", "showtext", "showtextdb", "snow", "snpStats", "spatstat", "stats", "stats4", "stringr", "survival", "sysfonts", "tensor", "tiff", "tissuesGeneExpression", "tools", "trimcluster", "TxDb.Hsapiens.UCSC.hg19.knownGene", "utils", "VariantAnnotation", "vegan", "VennDiagram", "vsn", "whisker", "xkcd", "XML", "xtable", "XVector", "yaml", "yeastCC", "zlibbioc")

## omit packages not supported on WIN and MAC
type = getOption("pkgType")
if ( type == "win.binary" || type == "mac.binary" ) {
  #  deps = setdiff(deps, c('gmapR'))
}
toInstall = deps[which( !deps %in% rownames(installed.packages()))]

## set up directory where downloaded packages are stored
destdir = NULL
            
if (interactive()) {
  cat(sprintf("\nDownloaded packages will be stored in %s.\n\nPress enter to proceed (recommended) or provide a different path: ", file.path(Sys.getenv("R_SESSION_TMPDIR"), "downloaded_packages")))
  answer <- readLines(n = 1)
  if(nchar(answer) > 1) 
    destdir = answer
}

# do not compile from sources
options(install.packages.compile.from.source = "never")
biocLite(toInstall, siteRepos = c(
  CSAMA  = paste0(.baseurl, "/packages/csama/"),
  GitHub = paste0(.baseurl, "/packages/github/")),
  type = ifelse(type == "source", "source", "both"),
  destdir = destdir)

if(all( deps %in% rownames(installed.packages()) )) {
  cat(sprintf("\nCongratulations! All packages were installed successfully :)\nWe are looking forward to seeing you in Brixen!\n\n"))
} else {
  notinstalled <- deps[which( !deps %in% rownames(installed.packages()) )]
  
  cat(sprintf("\nThe following package%s not installed: %s.\nPlease try re-running the script to see whether the problem persists.\nIf you need help with troubleshooting, consider contacting the course organisers, or the Bioconductor mailing list.\n\n",
    if (length(notinstalled)<=1) " was" else "s were", paste( notinstalled, collapse=", " )))
  
  if( .Platform$pkgType == "source" )
    cat("Some of the packages (e.g. 'Cairo', 'fftwtools', 'mzR', rgl', 'RCurl', 'tiff', 'XML') that failed to install may require additional system libraries.*  Please check the documentation of these packages for unsatisfied dependencies.\n\n*) For example, on Ubuntu the dependencies corresponding to the mentioned packages are: libcairo2-dev, libfftw3-dev, libnetcdf-dev, libglu1-mesa-dev, libcurl4-openssl-dev, libtiff4-dev and libxml2-dev, respectively.\n\n")
}
