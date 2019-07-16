#!/bin/bash
#
wget="wget -r -np -l 1 -A gz,zip,tgz -erobots=off"
R_ver=3.6
Bioc_ver=3.9
#
# Bioconductor
#
# Prefetch packages from local mirror using wget

$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/bioc/src/contrib/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/bioc/bin/windows/contrib/$R_ver/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/bioc/bin/macosx/el-capitan/contrib/$R_ver/

$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/annotation/src/contrib/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/annotation/bin/windows/contrib/$R_ver/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/annotation/bin/macosx/el-capitan/contrib/$R_ver/

$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/experiment/src/contrib/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/experiment/bin/windows/contrib/$R_ver/
$wget http://bioconductor.statistik.tu-dortmund.de/packages/$Bioc_ver/data/experiment/bin/macosx/el-capitan/contrib/$R_ver/

#mv bioconductor.statistik.tu-dortmund.de/packages/${Bioc_ver} $HOME/R_packages/bioc_${Bioc_ver}

