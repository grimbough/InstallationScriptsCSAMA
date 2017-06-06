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
deps = c("abind", "acepack", "ada", "affy", "affydata", "airway", "ALL", "annotate", "AnnotationDbi", "AnnotationFilter", "AnnotationForge", "AnnotationHub", "ArrayExpress", "assertthat", "base64enc", "BatchJobs", "BBmisc", "beeswarm", "BH", "Biobase", "BiocCheck", "BiocGenerics", "BiocInstaller", "BiocParallel", "BiocStyle", "biocViews", "biomaRt", "Biostrings", "biovizBase", "bitops", "bladderbatch", "bookdown", "boot", "BradleyTerry2", "BRAIN", "broom", "BSgenome", "BSgenome.Celegans.UCSC.ce2", "BSgenome.Dmelanogaster.UCSC.dm3", "BSgenome.Hsapiens.NCBI.GRCh38", "BSgenome.Hsapiens.UCSC.hg18", "BSgenome.Hsapiens.UCSC.hg19", "BSgenome.Mmusculus.UCSC.mm10", "BSgenome.Scerevisiae.UCSC.sacCer2", "Cairo", "car", "caret", "Category", "caTools", "chemometrics", "chipseq", "chron", "circlize", "class", "clue", "cluster", "cmprsk", "codetools", "colorspace", "ComplexHeatmap", "corrplot", "covr", "crosstalk", "Cubist", "curatedMetagenomicData", "curl", "data.table", "datasets", "DBI", "DelayedArray", "deldir", "dendextend", "dendsort", "DESeq", "DESeq2", "devtools", "DEXSeq", "dichromat", "digest", "doParallel", "dplyr", "drosophila2probe", "dsQTL", "DT", "dtplyr", "e1071", "earth", "edgeR", "ellipse", "EnsDb.Hsapiens.v75", "EnsDb.Hsapiens.v86", "ensembldb", "erma", "evaluate", "ExperimentHub", "extrafont", "faahKO", "fastcluster", "fastICA", "FDb.UCSC.tRNAs", "fdrtool", "ff", "ffbase", "fission", "FNN", "foreach", "foreign", "formatR", "Formula", "fpc", "futile.logger", "gam", "gbm", "gdata", "genefilter", "geneplotter", "GenomeInfoDb", "GenomeInfoDbData", "GenomicAlignments", "GenomicFeatures", "GenomicFiles", "GenomicRanges", "GEOquery", "geosphere", "GetoptLong", "geuvPack", "geuvStore2", "GGally", "ggbeeswarm", "ggbio", "ggplot2", "ggplot2movies", "ggpubr", "ggthemes", "ggvis", "Glimma", "glmnet", "GlobalOptions", "globaltest", "GO.db", "golubEsets", "GOstats", "gplots", "gpls", "gQTLBase", "gQTLstats", "graph", "graphics", "grDevices", "grid", "gridExtra", "GSEABase", "gtable", "gtools", "Gviz", "gwascat", "gWidgets", "HardyWeinberg", "HDF5Array", "Heatplus", "hexbin", "hgu133a.db", "hgu133aprobe", "hgu133plus2.db", "hgu95av2.db", "hgu95av2cdf", "hgu95av2probe", "highr", "Hiiragi2013", "HilbertCurve", "Hmisc", "hms", "hom.Hs.inp.db", "Homo.sapiens", "hpar", "htmlTable", "htmltools", "htmlwidgets", "httr", "hu6800.db", "humanStemCell", "hwriter", "igraph", "IHW", "impute", "imputeLCMD", "interactiveDisplay", "interactiveDisplayBase", "intergraph", "IPPD", "ipred", "IRanges", "IRdisplay", "isobar", "iterators", "itertools", "jpeg", "jsonlite", "KEGG.db", "KEGGgraph", "keggorthology", "KEGGREST", "kernlab", "KernSmooth", "klaR", "KMsurv", "knitr", "Lahman", "lars", "lattice", "latticeExtra", "lazyeval", "ldblock", "limma", "lintr", "listviewer", "locfit", "lpsymphony", "lubridate", "magick", "magrittr", "MALDIquant", "MALDIquantForeign", "mapproj", "maps", "maptools", "markdown", "MASS", "MassSpecWavelet", "Matrix", "matrixStats", "maxstat", "mboost", "mclust", "mda", "metagenomeSeq", "methods", "mgcv", "mice", "microbenchmark", "microRNA", "mirbase.db", "misc3d", "mlbench", "MLInterfaces", "MLmetrics", "ModelMetrics", "mouse4302.db", "msdata", "MSGFgui", "MSGFplus", "msmsEDA", "msmsTests", "MSnbase", "MSnID", "multcomp", "MultiAssayExperiment", "multtest", "mvtnorm", "mzID", "mzR", "ncdf4", "network", "nlme", "nnet", "norm", "nycflights13", "org.At.tair.db", "org.Hs.eg.db", "org.Mm.eg.db", "org.Sc.sgd.db", "OrganismDbi", "OrgMassSpecR", "orientlib", "packagedocs", "pamr", "pander", "parallel", "party", "pasilla", "pasillaBamSubset", "pbapply", "pcaMethods", "PFAM.db", "pheatmap", "phyloseq", "plotly", "pls", "plyr", "png", "PoiClaClu", "PolyPhen.Hsapiens.dbSNP131", "preprocessCore", "prettydoc", "pROC", "progress", "pRoloc", "pRolocdata", "ProtGenerics", "proxy", "pryr", "purrr", "pvclust", "quantreg", "qvalue", "R.cache", "R.utils", "R6", "RaggedExperiment", "randomForest", "RANN", "rBiopaxParser", "RColorBrewer", "Rcpp", "RcppArmadillo", "RCurl", "rda", "Rdisop", "reactome.db", "readBrukerFlexData", "readr", "ReportingTools", "reshape", "reshape2", "RforProteomics", "rgl", "Rgraphviz", "rhdf5", "RISmed", "rjson", "rlang", "rmarkdown", "rms", "RMySQL", "RNAseqData.HNRNPC.bam.chr14", "rnaseqGene", "ROC", "rols", "roxygen2", "rpart", "rprojroot", "rpx", "Rsamtools", "RSclient", "RSelenium", "Rserve", "RSQLite", "rstudioapi", "Rsubread", "rTANDEM", "rtracklayer", "Rtsne", "RUnit", "S4Vectors", "sampling", "scagnostics", "scales", "scater", "seqc", "sf", "sfsmisc", "shiny", "shinydashboard", "shinyFiles", "shinyjs", "ShortRead", "showtext", "showtextdb", "SIFT.Hsapiens.dbSNP132", "SIFT.Hsapiens.dbSNP137", "slam", "sna", "snow", "SNPlocs.Hsapiens.dbSNP.20101109", "SNPlocs.Hsapiens.dbSNP141.GRCh38", "snpStats", "som", "SparseM", "splines", "spls", "statmod", "stats", "stats4", "stringi", "stringr", "subselect", "SummarizedExperiment", "superpc", "survival", "survminer", "survMisc", "sva", "svglite", "synapter", "synapterdata", "sysfonts", "tables", "tcltk", "testit", "testthat", "threejs", "tibble", "tidyr", "tidyverse", "tiff", "tikzDevice", "tkWidgets", "tools", "topGO", "tufte", "TxDb.Athaliana.BioMart.plantsmart22", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Hsapiens.UCSC.hg18.knownGene", "TxDb.Hsapiens.UCSC.hg19.knownGene", "TxDb.Hsapiens.UCSC.hg19.lincRNAsTranscripts", "TxDb.Hsapiens.UCSC.hg38.knownGene", "TxDb.Mmusculus.UCSC.mm10.knownGene", "TxDb.Mmusculus.UCSC.mm9.knownGene", "tximport", "tximportData", "UpSetR", "utils", "VariantAnnotation", "vcd", "VennDiagram", "vipor", "viridis", "viridisLite", "vsn", "waveslim", "webshot", "withr", "xcms", "xkcd", "xlsx", "XML", "xtable", "XVector", "yaml", "yriMulti", "zebrafishRNASeq", "zlibbioc", "zoo")

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
