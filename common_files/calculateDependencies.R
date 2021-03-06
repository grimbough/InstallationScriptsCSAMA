args = commandArgs(trailingOnly=TRUE)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

target = tolower(args[1])
if(!target %in% c("server", "user")) {
    stop("Script must be invoked with either 'server' or 'user'")
}

# read package requirements from file
pkgs = readLines("../common_files/packages.txt")
# remove empty lines
pkgs = pkgs[nchar(pkgs)>0]
# remove comments
pkgs = pkgs[!grepl("^#", pkgs)]
# remove trailing whitespace
pkgs <- gsub(x = pkgs, pattern = " +$", replacement = "")
# intersect
pkgs <- unique(pkgs)

required = c("pkgDepTools", "Biobase", "tools")
installed_idx <- which(!required %in% rownames(installed.packages()))
for(i in seq_along(installed_idx)) {
    BiocManager::install(required[i], update = FALSE, ask = FALSE)
}

for(i in required)
    suppressPackageStartupMessages(require(i, character.only = TRUE) || stop(sprintf("need package '%s'", i)))

pkgsBuild = list.files("../common_files/additional_packages/")
pkgs = unique( c( pkgsBuild, pkgs ) )

##TODO: make this optional later
buildPackages = FALSE

### build packages in current repository
if(target == "user") {
    if( buildPackages ){
        for(i in pkgsBuild){
            system( sprintf("cd ../common_files/additional_packages && R CMD build %s", i) )
        }
        tarballs <- list.files(path = '../common_files/additional_packages', pattern = "tar.gz$", full.names = TRUE)
        ## copy the built packages to the new repo structure
        if(length(tarballs)) {
            file.copy(from = tarballs, 
                      to = "../common_files/csama_repo/src/contrib",
                      overwrite = TRUE)
            file.remove(tarballs)
        }
        write_PACKAGES("../common_files/csama_repo/src/contrib", verbose=TRUE, type="source")
        write_PACKAGES("../common_files/csama_repo/bin/windows/contrib/3.6/", verbose=TRUE, type="win.binary")
        write_PACKAGES("../common_files/csama_repo/bin/macosx/el-capitan/contrib/3.6/", verbose=TRUE, type="mac.binary")
    }
} else if(target == "server") {
    if( buildPackages ){
        for(i in pkgsBuild){
            system( sprintf("cd /home/csama/R_packages/bioc_3.9/bioc/src/contrib/ && R CMD build /home/csama/github/InstallationScriptsCSAMA/additionalPackages/src/contrib/%s", i) )
        }
        write_PACKAGES("/home/csama/R_packages/bioc_3.9/bioc/src/contrib", verbose=TRUE, type="source")
        write_PACKAGES("/home/csama/R_packages/bioc_3.9/bioc/bin/windows/contrib/3.6/", verbose=TRUE, type="win.binary")
        write_PACKAGES("/home/csama/R_packages/bioc_3.9/bioc/bin/macosx/contrib/3.6/", verbose=TRUE, type="mac.binary")
    }
}


options(repos="https://cloud.r-project.org/")
options(BioC_mirror="http://bioconductor.statistik.tu-dortmund.de") 


repoList <- BiocManager::repositories()
pkgMatList <- lapply(repoList, function(x) {
    available.packages(contrib.url(x, type = "source"))
})

deps <- c()

for (pMat in pkgMatList) {
    pcks <- pkgs[which(pkgs %in% rownames(pMat))]
    if (length(pcks))
        for ( p in pcks )
            deps <- c(deps, 
                      #pkgDepTools:::cleanPkgField(pMat[p, "Depends"]),
                      #pkgDepTools:::cleanPkgField(pMat[p, "Imports"]),
                      pkgDepTools:::cleanPkgField(pMat[p, "LinkingTo"])
                      #pkgDepTools:::cleanPkgField(pMat[p, "Suggests"])
            )
}

deps <- sort(unique(c(deps, pkgs)))
deps <- setdiff(deps, c("Rmpi"))
deps <- paste0('c("',paste(deps, collapse='", "'), '")')

# load templates
template <- switch(target, 
                   user = readLines("./installPackages.template"),
                   server = readLines("./installPackages_local.template"))
# inject list of required packages
template <- sub("@DEPS@", deps, template)
# write ready-to-use script files
cat(template, file="./install_packages.R", sep="\n")
#cat(server, file="/home/csama/Bressanone2016/server/public_html/installPackages.R", sep="\n")
