##------------------------------------------------------------
## Installation script for CSAMA 2017
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

.baseurl = c( biocinstallRepos(), "http://www-huber.embl.de/users/msmith/csama2017/csama_repo")

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
deps = c("ALL", "AnnotationDbi", "AnnotationForge", "AnnotationHub", "ArrayExpress", "BBmisc", "BH", "BRAIN", "BSgenome", "BSgenome.Celegans.UCSC.ce2", "BSgenome.Dmelanogaster.UCSC.dm3", "BSgenome.Hsapiens.NCBI.GRCh38", "BSgenome.Hsapiens.UCSC.hg18", "BSgenome.Hsapiens.UCSC.hg19", "BSgenome.Mmusculus.UCSC.mm10", "BSgenome.Scerevisiae.UCSC.sacCer2", "BatchJobs", "Biobase", "BiocCheck", "BiocGenerics", "BiocInstaller", "BiocParallel", "BiocStyle", "Biostrings", "BradleyTerry2", "Cairo", "Category", "ComplexHeatmap", "Cubist", "DBI", "DESeq", "DESeq2", "DEXSeq", "DT", "DelayedArray", "EnsDb.Hsapiens.v75", "EnsDb.Hsapiens.v86", "ExperimentHub", "FDb.UCSC.tRNAs", "FNN", "Formula", "GEOquery", "GGally", "GO.db", "GOstats", "GSEABase", "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicFiles", "GenomicRanges", "GetoptLong", "Glimma", "GlobalOptions", "Gviz", "HDF5Array", "Heatplus", "Hiiragi2013", "HilbertCurve", "Hmisc", "Homo.sapiens", "IHW", "IPPD", "IRanges", "IRdisplay", "KEGG.db", "KEGGREST", "KEGGgraph", "KMsurv", "KernSmooth", "Lahman", "MALDIquant", "MALDIquantForeign", "MASS", "MLInterfaces", "MLmetrics", "MSGFgui", "MSGFplus", "MSnID", "MSnbase", "MassSpecWavelet", "Matrix", "ModelMetrics", "MultiAssayExperiment", "OrgMassSpecR", "OrganismDbi", "PFAM.db", "PoiClaClu", "PolyPhen.Hsapiens.dbSNP131", "ProtGenerics", "R.cache", "R.utils", "R6", "RANN", "RColorBrewer", "RCurl", "RISmed", "RMySQL", "RNAseqData.HNRNPC.bam.chr14", "ROC", "RPostgreSQL", "RSQLite", "RSclient", "RSelenium", "RUnit", "RaggedExperiment", "Rcpp", "RcppArmadillo", "Rdisop", "ReportingTools", "RforProteomics", "Rgraphviz", "Rsamtools", "Rserve", "Rsubread", "S4Vectors", "SIFT.Hsapiens.dbSNP132", "SIFT.Hsapiens.dbSNP137", "SNPlocs.Hsapiens.dbSNP.20101109", "SNPlocs.Hsapiens.dbSNP.20110815", "SNPlocs.Hsapiens.dbSNP141.GRCh38", "ShortRead", "SparseM", "SummarizedExperiment", "TxDb.Athaliana.BioMart.plantsmart22", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Hsapiens.UCSC.hg18.knownGene", "TxDb.Hsapiens.UCSC.hg19.knownGene", "TxDb.Hsapiens.UCSC.hg19.lincRNAsTranscripts", "TxDb.Hsapiens.UCSC.hg38.knownGene", "TxDb.Mmusculus.UCSC.mm10.knownGene", "TxDb.Mmusculus.UCSC.mm9.knownGene", "UpSetR", "VariantAnnotation", "VennDiagram", "XML", "XVector", "abind", "acepack", "ada", "affy", "affydata", "airway", "annotate", "assertthat", "base64enc", "beeswarm", "biocViews", "biomaRt", "biovizBase", "bitops", "bladderbatch", "boot", "broom", "caTools", "car", "caret", "chemometrics", "chipseq", "chron", "circlize", "class", "clue", "cluster", "cmprsk", "codetools", "colorspace", "corrplot", "covr", "crosstalk", "curatedMetagenomicData", "curl", "data.table", "datasets", "deepSNV", "deldir", "dendextend", "dendsort", "devtools", "dichromat", "digest", "doParallel", "dplyr", "drosophila2probe", "dsQTL", "dtplyr", "e1071", "earth", "edgeR", "ellipse", "ensembldb", "erma", "evaluate", "extrafont", "faahKO", "fastICA", "fastcluster", "fdrtool", "ff", "ffbase", "fission", "foreach", "foreign", "formatR", "fpc", "futile.logger", "gQTLBase", "gQTLstats", "gWidgets", "gam", "gbm", "gdata", "genefilter", "geneplotter", "geosphere", "geuvPack", "geuvStore2", "ggbeeswarm", "ggbio", "ggplot2", "ggplot2movies", "ggpubr", "ggthemes", "ggvis", "glmnet", "globaltest", "golubEsets", "gplots", "gpls", "grDevices", "graph", "graphics", "grid", "gridExtra", "gtable", "gtools", "hexbin", "hgu133a.db", "hgu133aprobe", "hgu133plus2.db", "hgu95av2.db", "hgu95av2cdf", "hgu95av2probe", "highr", "hms", "hom.Hs.inp.db", "hpar", "htmlTable", "htmltools", "htmlwidgets", "httr", "hu6800.db", "humanStemCell", "hwriter", "igraph", "impute", "imputeLCMD", "interactiveDisplay", "interactiveDisplayBase", "intergraph", "ipred", "isobar", "iterators", "itertools", "jpeg", "jsonlite", "keggorthology", "kernlab", "klaR", "knitr", "lars", "lattice", "latticeExtra", "lazyeval", "ldblock", "limma", "lintr", "listviewer", "locfit", "lpsymphony", "lubridate", "magick", "magrittr", "mapproj", "maps", "maptools", "markdown", "matrixStats", "maxstat", "mboost", "mclust", "mda", "methods", "mgcv", "mice", "microRNA", "microbenchmark", "mirbase.db", "misc3d", "mlbench", "mouse4302.db", "msdata", "msmsEDA", "msmsTests", "multcomp", "multtest", "mvtnorm", "mzID", "mzR", "ncdf4", "network", "nlme", "nnet", "norm", "nycflights13", "org.At.tair.db", "org.Hs.eg.db", "org.Mm.eg.db", "org.Sc.sgd.db", "orientlib", "pROC", "pRoloc", "pRolocdata", "packagedocs", "pamr", "pander", "parallel", "party", "pasilla", "pasillaBamSubset", "pcaMethods", "pheatmap", "phyloseq", "plotly", "pls", "plyr", "png", "preprocessCore", "prettydoc", "progress", "proxy", "pryr", "purrr", "pvclust", "quantreg", "qvalue", "rBiopaxParser", "rTANDEM", "randomForest", "rda", "reactome.db", "readBrukerFlexData", "readr", "reshape", "reshape2", "rgl", "rlang", "rmarkdown", "rms", "rnaseqGene", "rols", "roxygen2", "rpart", "rprojroot", "rpx", "rstudioapi", "rtracklayer", "sampling", "scagnostics", "scales", "seqc", "sf", "sfsmisc", "shiny", "shinyFiles", "shinydashboard", "shinyjs", "showtext", "showtextdb", "slam", "sna", "snow", "snpStats", "som", "splines", "spls", "statmod", "stats", "stats4", "stringi", "stringr", "subselect", "superpc", "survMisc", "survival", "survminer", "sva", "svglite", "synapter", "synapterdata", "sysfonts", "tables", "tcltk", "testit", "testthat", "threejs", "tibble", "tidyr", "tidyverse", "tiff", "tikzDevice", "tkWidgets", "tools", "topGO", "tsne", "tufte", "tximport", "tximportData", "utils", "vcd", "vipor", "viridis", "viridisLite", "vsn", "waveslim", "webshot", "withr", "xcms", "xkcd", "xlsx", "xtable", "yaml", "yriMulti", "zebrafishRNASeq", "zlibbioc", "zoo")

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

source("http://bioconductor.org/workflows.R")
workflowInstall("rnaseqGene")

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
    cat("Some of the packages (e.g. 'Cairo', 'fftwtools', 'mzR', rgl', 'RCurl', 'tiff', 'XML') that failed to install may require additional system libraries.*  Please check the documentation of these packages for unsatisfied dependencies.\n\n*).  A list of required libraries for Ubuntu can be found at http://www.huber.embl.de/users/msmith/csama2017/linux_libraries.html \n\n")
  }
}
