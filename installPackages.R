##------------------------------------------------------------
## Installation script for CSAMA 2015
##------------------------------------------------------------

.required_R_version = c( "3.3.0", "3.3.1" )
.required_Bioc_version = "3.3"
.Bioc_devel_version = "3.4"
.required_rstudio_version = "0.99.1241"
.rstudio_url="https://www.rstudio.com/products/rstudio/download/preview/"
options(warn = 1)
#.baseurl = "http://www-huber.embl.de"
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
if( !(R_version %in% .required_R_version) )
  stop(sprintf("You are using a version of R different than the one required for CSAMA'%s, please install R-%s", .yr, .required_R_version[2]))

## Install Bioconductor
source("http://bioconductor.org/biocLite.R")
chooseBioCmirror()
chooseCRANmirror()

.baseurl = c( biocinstallRepos(), "http://www-huber.embl.de/users/reyes/csama2016/additionalPackages")

### Check Rstudio version
hasApistudio = suppressWarnings(require("rstudioapi", quietly=TRUE))
if( !hasApistudio ){
  biocLite("rstudioapi", suppressUpdates=TRUE, siteRepos = .baseurl)
  suppressWarnings(require("rstudioapi", quietly=TRUE))
}

.rstudioVersion = try( rstudioapi::versionInfo()$version, silent=TRUE )
if( inherits( .rstudioVersion, "try-error" ) ){
  .rstudioVersion = gsub("\n|Error : ", "", .rstudioVersion)
  rstudioError = sprintf("The following error was produced while checking your Rstudio version: \"%s\"\nPlease make sure that you are running this script from an Rstudio session. If you are doing so and the error persists, please contact the organisers of CSAMA'%s.\n", .rstudioVersion, .yr)
  stop( rstudioError )
}

if( !( .rstudioVersion >= .required_rstudio_version ) ){
  rstudioVersionError = sprintf("You are using a version of Rstudio different from the one required for CSAMA'%s, please install Rstudio v%s.\nRstudio v%s can be found here: %s",
    .yr, .required_rstudio_version, .required_rstudio_version, .rstudio_url)
  stop( rstudioVersionError )
}

if( biocVersion() == .Bioc_devel_version )
  useDevel(devel = FALSE)

if( biocVersion() != .required_Bioc_version )
  stop(sprintf("Please install Bioconductor %s\n", .required_Bioc_version))

## Get list of packages to install
deps = c("acepack", "affy", "airway", "annotate", "AnnotationDbi", "AnnotationHub", "assertthat", "BatchJobs", "BBmisc", "beeswarm", "BH", "Biobase", "BiocGenerics", "BiocInstaller", "BiocParallel", "BiocStyle", "biomaRt", "Biostrings", "biovizBase", "bit", "bitops", "boot", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "caTools", "chipseq", "class", "clue", "cluster", "colorspace", "crayon", "curatedOvarianData", "data.table", "DBI", "DESeq", "DESeq2", "devtools", "dichromat", "digest", "diptest", "doParallel", "downloader", "dplyr", "edgeR", "ensembldb", "EpigeneticsCSAMA", "epitools", "erma", "evaluate", "fdrtool", "ff", "ffbase", "flexmix", "foreach", "foreign", "formatR", "Formula", "fpc", "futile.logger", "gapminder", "gbm", "gdata", "genefilter", "geneplotter", "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicFiles", "GenomicRanges", "geuvPack", "geuvStore2", "GGally", "ggbio", "ggplot2", "ggthemes", "ggvis", "git2r", "Glimma", "GO.db", "gplots", "gQTLBase", "gQTLstats", "graph", "graphics", "grDevices", "grid", "gridExtra", "gtable", "gtools", "Gviz", "gwascat", "hexbin", "hgu133a.db", "hgu95av2.db", "highr", "Hiiragi2013", "HistData", "Hmisc", "Homo.sapiens", "htmltools", "httpuv", "httr", "hwriter", "IHW", "impute", "interactiveDisplayBase", "IRanges", "jsonlite", "KEGGREST", "kernlab", "KernSmooth", "knitr", "labeling", "lattice", "latticeExtra", "lazyeval", "limma", "locfit", "lpsymphony", "magrittr", "markdown", "MASS", "Matrix", "matrixStats", "mclust", "memoise", "metafor", "methods", "mgcv", "microbenchmark", "mime", "mlbench", "MLInterfaces", "mouse4302.db", "munsell", "mvtnorm", "nnet", "OrganismDbi", "org.Hs.eg.db", "org.Mm.eg.db", "parallel", "pheatmap", "pls", "plyr", "png", "PoiClaClu", "prabclus", "praise", "purrr", "R6", "rafalib", "RColorBrewer", "Rcpp", "RcppArmadillo", "RCurl", "rda", "reshape2", "rgl", "rmarkdown", "RNAseqData.HNRNPC.bam.chr14", "robustbase", "rpart", "Rsamtools", "RSQLite", "rstudioapi", "Rsubread", "rtracklayer", "S4Vectors", "scales", "sfsmisc", "shiny", "ShortRead", "slam", "snow", "snpStats", "SparseM", "splines", "stats", "stats4", "stringi", "stringr", "SummarizedExperiment", "survival", "testthat", "threejs", "tibble", "tidyr", "tissuesGeneExpression", "tools", "topGO", "trimcluster", "TxDb.Hsapiens.UCSC.hg19.knownGene", "tximport", "tximportData", "UsingR", "utils", "VariantAnnotation", "VennDiagram", "whisker", "withr", "XML", "xtable", "XVector", "yaml", "yeastCC", "zlibbioc")

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
biocLite(toInstall, siteRepos = .baseurl,
  type = ifelse(type == "source", "source", "both"),
  destdir = destdir)

if(all( deps %in% rownames(installed.packages()) )) {
  cat(sprintf("\nCongratulations! All packages were installed successfully :)\nWe are looking forward to seeing you in Brixen!\n\n"))
} else {
  notinstalled <- deps[which( !deps %in% rownames(installed.packages()) )]
  
  cat(sprintf("\nThe following package%s not installed:\n\n%s\n\nPlease try re-running the script to see whether the problem persists.\nIf you need help with troubleshooting, consider contacting the course organisers, or the Bioconductor mailing list.\n\n",
    if (length(notinstalled)<=1) " was" else "s were", paste( notinstalled, collapse="\n" )))
  
  if( .Platform$pkgType == "source" )
    cat("Some of the packages (e.g. 'Cairo', 'fftwtools', 'mzR', rgl', 'RCurl', 'tiff', 'XML') that failed to install may require additional system libraries.*  Please check the documentation of these packages for unsatisfied dependencies.\n\n*) For example, on Ubuntu the dependencies corresponding to the mentioned packages are: libcairo2-dev, libfftw3-dev, libnetcdf-dev, libglu1-mesa-dev, libcurl4-openssl-dev, libtiff4-dev and libxml2-dev, respectively.\n\n")
}
