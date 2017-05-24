##------------------------------------------------------------
## Installation script for CSAMA 2016
##------------------------------------------------------------

.required_R_version = c( "3.4.0", "3.4.0" )
.required_Bioc_version = "3.5"
.Bioc_devel_version = "3.6"
.required_rstudio_version = "1.0.143"
.rstudio_url="https://www.rstudio.com/products/rstudio/download/"
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
#chooseBioCmirror()
#chooseCRANmirror()

.baseurl = c( biocinstallRepos(), "http://www-huber.embl.de/users/msmith/csama2017/additionalPackages")

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
  rstudioVersionError = sprintf("You are using a version of Rstudio different from the one required for CSAMA'%s, please install Rstudio v%s or higher.\nThe preview version of Rstudio can be found here: %s",
    .yr, .required_rstudio_version, .rstudio_url)
  stop( rstudioVersionError )
}

if( biocVersion() == .Bioc_devel_version )
  useDevel(devel = FALSE)

if( biocVersion() != .required_Bioc_version )
  stop(sprintf("Please install Bioconductor %s\n", .required_Bioc_version))

## Get list of packages to install
deps = c("acepack", "affy", "airway", "annotate", "AnnotationDbi", "AnnotationFilter", "AnnotationHub", "ArrayExpress", "assertthat", "base64enc", "beeswarm", "BH", "Biobase", "BiocGenerics", "BiocInstaller", "BiocParallel", "BiocStyle", "biocViews", "biomaRt", "Biostrings", "biovizBase", "bitops", "bookdown", "boot", "BradleyTerry2", "BRAIN", "broom", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "BSgenome.Mmusculus.UCSC.mm10", "BSgenome.Scerevisiae.UCSC.sacCer2", "Cairo", "car", "caret", "chemometrics", "chipseq", "chron", "class", "clue", "cluster", "colorspace", "corrplot", "covr", "crosstalk", "Cubist", "curl", "data.table", "datasets", "DBI", "deldir", "dendextend", "DESeq2", "devtools", "DEXSeq", "dichromat", "digest", "doParallel", "dplyr", "DT", "dtplyr", "e1071", "earth", "edgeR", "ellipse", "EnsDb.Hsapiens.v75", "ensembldb", "ExperimentHub", "extrafont", "faahKO", "fastICA", "fdrtool", "ff", "ffbase", "FNN", "foreach", "foreign", "Formula", "gam", "genefilter", "geneplotter", "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicRanges", "GEOquery", "geosphere", "GGally", "ggbeeswarm", "ggbio", "ggplot2", "ggplot2movies", "ggthemes", "glmnet", "GO.db", "gplots", "graphics", "grDevices", "grid", "gridExtra", "gtable", "gtools", "Gviz", "gWidgets", "Heatplus", "hexbin", "hgu95av2.db", "hgu95av2probe", "Hiiragi2013", "Hmisc", "hms", "Homo.sapiens", "hpar", "htmlTable", "htmltools", "htmlwidgets", "httr", "igraph", "IHW", "impute", "imputeLCMD", "interactiveDisplay", "intergraph", "IPPD", "ipred", "IRanges", "IRdisplay", "isobar", "iterators", "jsonlite", "KEGG.db", "KEGGgraph", "KEGGREST", "kernlab", "KernSmooth", "klaR", "knitr", "Lahman", "lars", "lattice", "latticeExtra", "lazyeval", "lintr", "listviewer", "locfit", "lpsymphony", "lubridate", "magick", "magrittr", "MALDIquant", "MALDIquantForeign", "mapproj", "maps", "maptools", "MASS", "MassSpecWavelet", "Matrix", "mclust", "mda", "methods", "mgcv", "mice", "microbenchmark", "misc3d", "mlbench", "MLInterfaces", "MLmetrics", "ModelMetrics", "mouse4302.db", "msdata", "MSGFgui", "MSGFplus", "msmsEDA", "msmsTests", "MSnbase", "MSnID", "multcomp", "multtest", "mvtnorm", "mzID", "mzR", "ncdf4", "network", "nlme", "nnet", "norm", "nycflights13", "org.Hs.eg.db", "org.Mm.eg.db", "org.Sc.sgd.db", "OrganismDbi", "OrgMassSpecR", "orientlib", "packagedocs", "pamr", "pander", "parallel", "party", "pasilla", "pasillaBamSubset", "pbapply", "pcaMethods", "pheatmap", "plotly", "pls", "plyr", "png", "preprocessCore", "prettydoc", "pROC", "progress", "pRoloc", "pRolocdata", "ProtGenerics", "proxy", "pryr", "purrr", "quantreg", "qvalue", "R.cache", "R.utils", "R6", "randomForest", "RANN", "RColorBrewer", "Rcpp", "RcppArmadillo", "RCurl", "Rdisop", "readBrukerFlexData", "readr", "reshape", "reshape2", "RforProteomics", "rgl", "Rgraphiz", "rlang", "rmarkdown", "rms", "RMySQL", "RNAseqData.HNRNPC.bam.chr14", "rnaseqGene", "rols", "roxygen2", "rpart", "RPostgreSQL", "rpx", "Rsamtools", "RSclient", "RSelenium", "Rserve", "RSQLite", "rstudioapi", "rTANDEM", "rtracklayer", "Rtsne", "RUnit", "S4Vectors", "sampling", "scagnostics", "scales", "shiny", "shinyFiles", "shinyjs", "showtext", "showtextdb", "slam", "sna", "snow", "splines", "spls", "stats", "stats4", "stringi", "stringr", "subselect", "SummarizedExperiment", "superpc", "survival", "svglite", "synapter", "synapterdata", "sysfonts", "tables", "tcltk", "testthat", "tibble", "tidyr", "tidyverse", "tools", "TxDb.Athaliana.BioMart.plantsmart22", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Hsapiens.UCSC.hg19.knownGene", "TxDb.Mmusculus.UCSC.mm10.knownGene", "TxDb.Mmusculus.UCSC.mm9.knownGene", "tximport", "tximportData", "utils", "VariantAnnotation", "vcd", "VennDiagram", "vipor", "viridis", "viridisLite", "vsn", "webshot", "withr", "xcms", "xcms_2.99.1.tar.gz", "xkcd", "xlsx", "XML", "xtable", "XVector", "yaml", "zlibbioc", "zoo")

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


  if( .Platform$pkgType == "win.binary" & 'Rsubread' %in% notinstalled ){
    cat("The windows binaries for the package 'Rsubread' are not available. However, this package is not 100% necessary for the practicals. If this is the only package
    that was not installed, there is no reason to worry. \n")
  }
  
  cat(sprintf("\nThe following package%s not installed:\n\n%s\n\nPlease try re-running the script to see whether the problem persists.\nIf you need help with troubleshooting, consider contacting the course organisers, or the Bioconductor mailing list.\n\n",
    if (length(notinstalled)<=1) " was" else "s were", paste( notinstalled, collapse="\n" )))
  
  if( .Platform$pkgType == "source" ){
    cat("Some of the packages (e.g. 'Cairo', 'fftwtools', 'mzR', rgl', 'RCurl', 'tiff', 'XML') that failed to install may require additional system libraries.*  Please check the documentation of these packages for unsatisfied dependencies.\n\n*) For example, on Ubuntu the dependencies corresponding to the mentioned packages are: libcairo2-dev, libfftw3-dev, libnetcdf-dev, libglu1-mesa-dev, libcurl4-openssl-dev, libtiff4-dev and libxml2-dev, respectively.\n\n")
  }
}
