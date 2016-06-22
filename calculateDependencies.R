# read package requirements from file
pkgs = readLines("packages.txt")
# remove empty lines
pkgs = pkgs[nchar(pkgs)>0]
# remove comments
pkgs = pkgs[!grepl("^#", pkgs)]
# intersect
pkgs <- unique(pkgs)
#
source("http://bioconductor.org/biocLite.R")
options(repos="http://cran.r-mirror.de")
options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de") 
# 
required = c("pkgDepTools", "Biobase", "tools")
for(i in required)
  require(i, character.only = TRUE) || stop(sprintf("need package '%s'", i))
#
repList <- biocinstallRepos(siteRepos = c(
  CSAMA  = "http://www-huber.embl.de/packages/csama/",
  GitHub = "http://www-huber.embl.de/packages/github/"))
#
pkgMatList <- lapply(repList, function(x) {
  available.packages(contrib.url(x, type = "source"))
})
#
deps <- c()
#
for (pMat in pkgMatList) {
  pcks <- pkgs[which(pkgs %in% rownames(pMat))]
  if (length(pcks))
    for ( p in pcks )
      deps <- c(deps, 
                pkgDepTools:::cleanPkgField(pMat[p, "Depends"]),
                pkgDepTools:::cleanPkgField(pMat[p, "Imports"]),
                pkgDepTools:::cleanPkgField(pMat[p, "LinkingTo"])
                #pkgDepTools:::cleanPkgField(pMat[p, "Suggests"])
                )
}
#
deps <- sort(unique(c(deps, pkgs)))
#
#deps <- setdiff(deps, c("Rmpi", "xgboost"))
#
deps <- paste0('c("',paste(deps, collapse='", "'), '")')
# load templates
online = readLines("./installPackages.template")
server = readLines("../server/public_html/installPackages.template")
# inject list of required packages
online = sub("DEPS", deps, online)
server = sub("DEPS", deps, server)
# write ready-to-use script files
cat(online, file="./installPackages.R", sep="\n")
cat(server, file="../server/public_html/installPackages.R", sep="\n")
