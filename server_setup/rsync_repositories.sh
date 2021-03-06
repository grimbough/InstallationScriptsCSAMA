#!/bin/bash
#cd `dirname $0`

rsync="rsync --progress -rtzvhlam --delete --include-from rsync.include --filter '-! */'"
#rsync="rsync --progress --dry-run -zrtlvham --delete --include-from rsync.include --filter '-! */'"
Bioc_ver=3.9

eval $rsync master.bioconductor.org::release/ bioc_${Bioc_ver}/
eval $rsync cran.r-project.org::CRAN/ cran/
