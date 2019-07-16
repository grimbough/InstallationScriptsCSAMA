##------------------------------------------------------------
## Installation script for CSAMA 2019
##------------------------------------------------------------

##---------------------------
## Install BiocManager
##---------------------------
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
if (!requireNamespace("remotes", quietly = TRUE))
    BiocManager::install("remotes", quiet = TRUE, update = FALSE, ask = FALSE)
if (!requireNamespace("Biobase", quietly = TRUE))
    BiocManager::install("Biobase", quiet = TRUE, update = FALSE, ask = FALSE)

##-------------------------------------------
## installation function
##-------------------------------------------

installer_with_progress <- function(pkgs) {
    
    if(length(pkgs) == 0) { invisible(return(NULL)) }
    
    if(!requireNamespace("progress", quietly = TRUE)) {
      suppressMessages(
        BiocManager::install('progress', quiet = TRUE, update = FALSE, ask = FALSE)
      )
    }
    
    toInstall <- pkgs
    bp <- progress::progress_bar$new(total = length(toInstall),
                           format = "Installed :current of :total (:percent ) - current package: :package",
                           show_after = 0,
                           clear = FALSE)
    
    length_prev <- length(toInstall)
    fail <- NULL
    while(length(toInstall)) {
        pkg <- toInstall[1]
        bp$tick(length_prev - length(toInstall),  tokens = list(package = pkg))
        length_prev <- length(toInstall)
        if(pkg %in% rownames(installed.packages())) {
          toInstall <- toInstall[-1]
        } else {
          tryCatch(
              suppressMessages( BiocManager::install(pkg, quiet = TRUE, update = FALSE, ask = FALSE,
                                                     Ncpus = parallel::detectCores() ) ),
              error = function(e) { fail <<- c(fail, pkg) },
              warning = function(w) { fail <<- c(fail, pkg) },
              finally = toInstall <- toInstall[-1]
        )
        }
    }
    bp$tick(length_prev - length(toInstall),  tokens = list(package = "DONE!"))
    
    return(fail)
}

##-------------------------------------------
## System requirements
##-------------------------------------------
.required_R_version = c( "3.6.0", "3.6.1" )
.required_Bioc_version = "3.9"
.Bioc_devel_version = "3.10"
.required_rstudio_version = "1.2.1335"
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

.baseurl = c( BiocManager::repositories(), "http://www-huber.embl.de/users/msmith/csama2019/csama_repo")

### Check Rstudio version
hasApistudio = suppressWarnings(require("rstudioapi", quietly=TRUE))
if( !hasApistudio ){
  BiocManager::install("rstudioapi", update=FALSE, siteRepos = .baseurl, quiet = TRUE, ask = FALSE)
  suppressWarnings(require("rstudioapi", quietly=TRUE))
}

.rstudioVersion = try( rstudioapi::versionInfo()$version, silent=TRUE )
if( inherits( .rstudioVersion, "try-error" ) ){
  .rstudioVersion = gsub("\n|Error : ", "", .rstudioVersion)
  rstudioError = sprintf("The following error was produced while checking your Rstudio version: \"%s\"\nPlease make sure that you are running this script from an Rstudio session. If you are doing so and the error persists, please contact the organisers of CSAMA'%s.\n", .rstudioVersion, .yr)
  stop( rstudioError )
}

if( !( .rstudioVersion >= .required_rstudio_version ) ){
  rstudioVersionError = sprintf("You are using a version of Rstudio different from the one required for CSAMA'%s, please install Rstudio v%s or higher.\nThe latest version of Rstudio can be found here: %s",
    .yr, .required_rstudio_version, .rstudio_url)
  stop( rstudioVersionError )
}

#if( BiocManager::version() == .Bioc_devel_version )
#  useDevel(devel = FALSE)

if( BiocManager::version() != .required_Bioc_version )
  stop(sprintf("Please install Bioconductor %s\n", .required_Bioc_version))

## Get list of packages to install
deps <- c("affy", "airway", "annotate", "AnnotationDbi", "AnnotationHub", "ape", "apeglm", "assertthat", "base64enc", "batchelor", "beachmat", "beeswarm", "BH", "bigrquery", "Biobase", "BiocFileCache", "BiocGenerics", "BiocManager", "BiocNeighbors", "BiocParallel", "BiocSingular", "BiocStyle", "biocViews", "biomaRt", "Biostrings", "bookdown", "BSgenome", "BSgenome.Hsapiens.UCSC.hg19", "BSgenome.Hsapiens.UCSC.hg38", "callr", "caret", "Category", "class", "cli", "clipr", "cluster", "clusterExperiment", "coda", "colourpicker", "copula", "cowplot", "crayon", "curatedMetagenomicData", "curatedTCGAData", "curl", "data.table", "DBI", "dbplyr", "DelayedArray", "DelayedMatrixStats", "dendextend", "DESeq2", "devtools", "digest", "doParallel", "dplyr", "dqrng", "DT", "dynamicTreeCut", "e1071", "edgeR", "emdbook", "EnsDb.Hsapiens.v86", "ensembldb", "evaluate", "ExperimentHub", "extrafont", "extrafontdb", "fansi", "fdrtool", "FNN", "foreach", "fpc", "gbm", "gdata", "genefilter", "geneplotter", "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicRanges", "ggbeeswarm", "ggbio", "ggplot2", "ggvis", "git2r", "glmnet", "glue", "GO.db", "GOstats", "graph", "graphics", "grDevices", "grid", "GSEABase", "gtable", "gtools", "gwascat", "HDF5Array", "hexbin", "highr", "Hmisc", "hms", "Homo.sapiens", "howmany", "htmltools", "httr", "hugene20sttranscriptcluster.db", "HumanTranscriptomeCompendium", "hwriter", "igraph", "IHW", "impute", "interactiveDisplayBase", "IRanges", "irlba", "iSEE", "iterators", "jsonlite", "kernlab", "knitr", "LaplacesDemon", "lattice", "lazyeval", "limma", "locfdr", "locfit", "lpsymphony", "magick", "magrittr", "MALDIquant", "markdown", "MASS", "MassSpecWavelet", "Matrix", "matrixStats", "mclust", "memoise", "methods", "mgcv", "mikelove/airway2", "mime", "mixtools", "mlbench", "MLInterfaces", "msdata", "MSnbase", "MSnID", "multtest", "mvtnorm", "mzID", "mzR", "NMF", "nnet", "ontologyPlot", "ontoProc", "org.Hs.eg.db", "Organism.dplyr", "pander", "parallel", "pcaMethods", "PFAM.db", "pheatmap", "phylobase", "pillar", "pkgbuild", "pkgconfig", "pkgload", "plogr", "pls", "plyr", "png", "PoiClaClu", "pracma", "preprocessCore", "progress", "pRoloc", "pRolocdata", "ProtGenerics", "proxy", "R.cache", "R.utils", "R6", "randomForest", "RANN", "rappdirs", "rcmdcheck", "RColorBrewer", "Rcpp", "RcppAnnoy", "RcppArmadillo", "RcppEigen", "RcppNumerical", "RcppParallel", "RcppProgress", "RCurl", "rda", "readr", "remotes", "rentrez", "ReportingTools", "reshape2", "restfulSE", "RforProteomics", "rgl", "Rgraphviz", "rhdf5client", "rintrojs", "rjson", "rlang", "rmarkdown", "robustbase", "rols", "roxygen2", "rpart", "rpx", "Rsamtools", "RSpectra", "RSQLite", "rstudioapi", "rsvd", "rtracklayer", "Rtsne", "Rttf2pt1", "RUVSeq", "S4Vectors", "sampling", "scales", "scater", "scran", "scRNAseq", "sessioninfo", "sfsmisc", "shiny", "shinyAce", "shinydashboard", "shinyjs", "SingleCellExperiment", "slam", "slingshot", "softImpute", "ssrch", "statmod", "statOmics/MSqRob", "stats", "stats4", "stringr", "SummarizedExperiment", "survival", "sva", "sysfonts", "TENxPBMCData", "testthat", "threejs", "tibble", "tidyr", "tidyselect", "tinytex", "tools", "TxDb.Hsapiens.UCSC.hg19.knownGene", "TxDb.Hsapiens.UCSC.hg38.knownGene", "tximeta", "tximport", "TxRegInfra", "utils", "uwot", "vipor", "viridis", "viridisLite", "vsn", "withr", "xcms", "xfun", "XML", "xml2", "XVector", "yaml", "zinbwave", "zlibbioc")
deps <- data.frame(name = gsub(x = deps, "^[[:alnum:]]+/", ""),
                  source = deps, 
                  stringsAsFactors = FALSE)

## omit packages not supported on WIN and MAC
#type = getOption("pkgType")
#if ( type == "win.binary" || type == "mac.binary" ) {
  #  deps = setdiff(deps, c('gmapR'))
#}
toInstall = deps[which( !deps$name %in% rownames(installed.packages())), "source"]

## set up directory where downloaded packages are stored
destdir = NULL
            
#if (interactive()) {
#  cat(sprintf("\nDownloaded packages will be stored in %s.\n\nPress enter to proceed (recommended) or provide a different path: ", #file.path(Sys.getenv("R_SESSION_TMPDIR"), "downloaded_packages")))
#  answer <- readLines(n = 1)
#  if(nchar(answer) > 1) 
#    destdir = answer
#}

# do not compile from sources
options(install.packages.compile.from.source = "never")
if(.Platform$OS.type == "windows" || Sys.info()["sysname"] == "Darwin") {
  BiocManager::install(toInstall, ask = FALSE, quiet = TRUE, update = FALSE)
} else {
  fail <- installer_with_progress(toInstall)
}

##---------------------------
## Additional installation commands
##---------------------------
if(Biobase::package.version("msdata") < "0.24.1") {
  BiocManager::install(msdata, ask = FALSE, quiet = TRUE, update = FALSE)
}

TENxPBMCData::TENxPBMCData(dataset = "pbmc3k")
TENxPBMCData::TENxPBMCData(dataset = "pbmc4k")

library("ensembldb")
ah <- AnnotationHub::AnnotationHub()
ah_91 <- AnnotationHub::query(ah, "EnsDb.Hsapiens.v91")
edb <- ah[[names(ah_91)]]

##-------------------------
## Feedback on installation
##---------------------------
if(all( deps$name %in% rownames(installed.packages()) )) {
  cat(sprintf("\nCongratulations! All packages were installed successfully :)\nWe are looking forward to seeing you in Brixen!\n\n"))
} else {
  notinstalled <- deps[which( !deps$name %in% rownames(installed.packages()) ), "name"]


  if( .Platform$pkgType == "win.binary" & 'Rsubread' %in% notinstalled ){
    cat("The windows binaries for the package 'Rsubread' are not available. However, this package is not 100% necessary for the practicals. If this is the only package
    that was not installed, there is no reason to worry. \n")
  }
  
  cat(sprintf("\nThe following package%s not installed:\n\n%s\n\nPlease try re-running the script to see whether the problem persists.\nIf you need help with troubleshooting, consider contacting the course organisers, or the Bioconductor mailing list.\n\n",
    if (length(notinstalled)<=1) " was" else "s were", paste( notinstalled, collapse="\n" )))
  
  if( .Platform$pkgType == "source" ){
    message("Some of the packages (e.g. 'Cairo', 'mzR', rgl', 'RCurl', 'tiff', 'XML') that failed to install may require additional system libraries.*  Please check the documentation of these packages for unsatisfied dependencies.\n\n*).  A list of required libraries for Ubuntu can be found at http://www.huber.embl.de/users/msmith/csama2019/linux_libraries.html \n\n")
  }
}
