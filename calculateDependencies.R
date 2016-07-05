LOCAL <- TRUE

# read package requirements from file
pkgs = readLines("info/packages.txt")
# remove empty lines
pkgs = pkgs[nchar(pkgs)>0]
# remove comments
pkgs = pkgs[!grepl("^#", pkgs)]
# intersect
pkgs <- unique(pkgs)
#

required = c("pkgDepTools", "Biobase", "tools")
for(i in required)
  require(i, character.only = TRUE) || stop(sprintf("need package '%s'", i))

pkgsBuild = readLines("info/packagesToBuild.txt")
pkgs = unique( c( pkgsBuild, pkgs ) )


### build packages in current repository
if(!LOCAL) {
buildPackages = FALSE
if( buildPackages ){
  for(i in pkgsBuild){
    system( sprintf("cd additionalPackages/src/contrib && R CMD build %s", i) )
  }
  write_PACKAGES("additionalPackages/src/contrib", verbose=TRUE, type="source")
  write_PACKAGES("additionalPackages/bin/windows/contrib/3.3", verbose=TRUE, type="win.binary")
  write_PACKAGES("additionalPackages/bin/macosx/mavericks/contrib/3.3/", verbose=TRUE, type="mac.binary")
}

source("http://bioconductor.org/biocLite.R")
options(repos="http://cran.r-mirror.de")
options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de")  
} else {
buildPackages = TRUE
if( buildPackages ){
  for(i in pkgsBuild){
    system( sprintf("cd /home/csama/packages/rsync/3.3/bioc/src/contrib/ && R CMD build /home/csama/Bressanone2016/InstallationScriptsCSAMA2016/additionalPackages/src/contrib/%s", i) )
  }
  write_PACKAGES("/home/csama/packages/rsync/3.3/bioc/src/contrib", verbose=TRUE, type="source")
  write_PACKAGES("/home/csama/packages/rsync/3.3/bioc/bin/windows/contrib/3.3", verbose=TRUE, type="win.binary")
  write_PACKAGES("/home/csama/packages/rsync/3.3/bioc/bin/macosx/mavericks/contrib/3.3/", verbose=TRUE, type="mac.binary")
}

source("http://bioconductor.org/biocLite.R")
options(repos="http://cran.r-mirror.de")
options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de") 
}
#
repList <- biocinstallRepos()
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
                pkgDepTools:::cleanPkgField(pMat[p, "LinkingTo"]),
                pkgDepTools:::cleanPkgField(pMat[p, "Suggests"])
                )
}
#
deps <- sort(unique(c(deps, pkgs)))
#
deps <- setdiff(deps, c("Rmpi"))
#
deps <- paste0('c("',paste(deps, collapse='", "'), '")')
# load templates
#online = readLines("./installPackages.template")
server = readLines("./installPackages_local.template")
# inject list of required packages
#online = sub("DEPS", deps, online)
server = sub("DEPS", deps, server)
# write ready-to-use script files
#cat(online, file="./installPackages.R", sep="\n")
cat(server, file="/home/csama/Bressanone2016/server/public_html/installPackages.R", sep="\n")
