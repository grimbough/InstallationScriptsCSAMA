#!/bin/bash

## run the script creator in 'user' mode
Rscript --vanilla ../common_files/calculateDependencies.R "user"

## copy to the Huber group website
scp install_packages.R datatransfer.embl.de:/g/huber/www-huber/users/msmith/csama2018/

rsync -avz ../common_files/csama_repo datatransfer.embl.de:/g/huber/www-huber/users/msmith/csama2018/ 
