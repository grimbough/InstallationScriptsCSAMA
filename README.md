
Instructions for setting up the CSAMA local mirror and creating the installation scripts to be sent to the participants.

# Setting up the local server

## Inital Bioc and CRAN mirror

Run *wget_repositories.sh*.  This bulk downloads the whole of Bioconductor and CRAN and create the directory structure required for our own mirrors of both.  We only want to run this once as it's approximately 100GB of downloads, afterwards we can use *rsync_repositories.sh* which will only update the bits that have changed.

# Creating Installation Scripts

## Required CRAN and BioC packages

We maintain a list of the required packages in `info/packages.txt`

## Additional packages

If we have any additional packages that have only been created for the course e.g. data packages, these will need to be built.  Their names should be include in `info/additionalPackages.txt`, and the source folder for each should be placed in `./additionalPackages/src/contrib/`

## Building installation script

We can then run `calculateDependencies.R`, which will read the lists of packages we need and create the installation script to host on our website.  This script will also build the Windows and Mac binaries for any of the additional packages listed in the above section and make them available via our own repo.
