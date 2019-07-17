.baseurl = "http://192.168.0.5"

options("repos" = c(
   CRAN = paste0(.baseurl, "/packages/cran"),
))
options(BioC_mirror = .baseurl)