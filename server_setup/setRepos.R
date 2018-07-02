.baseurl = "http://192.168.0.9"

options("repos" = c(
   CRAN      = paste0(.baseurl, "/packages/cran"),
   BioCsoft  = paste0(.baseurl, "/packages/3.5/bioc"),
   BioCexp   = paste0(.baseurl, "/packages/3.5/data/experiment"),
   BioCann   = paste0(.baseurl, "/packages/3.5/data/annotation"),
   BioCextra = paste0(.baseurl, "/packages/3.5/extra"),
   CSAMA     = paste0(.baseurl, "/packages/csama_repo")
))
