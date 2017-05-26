
Instructions for setting up the CSAMA local mirror and creating the installation scripts to be sent to the participants.

# Setting up the local server

** We'll worry about this later **

## Inital Bioc and CRAN mirror

Run *wget_repositories.sh*.  This bulk downloads the whole of Bioconductor and CRAN and create the directory structure required for our own mirrors of both.  We only want to run this once as it's approximately 100GB of downloads, afterwards we can use *rsync_repositories.sh* which will only update the bits that have changed.

# Creating Installation Scripts

## Required CRAN and BioC packages

We maintain a list of the required packages in `common_files/packages.txt`.  I've been doing this manually by looking at the Rmd files in https://github.com/Bioconductor/CSAMA/tree/2017 and copy/pasting.  It doesn't matter if there are duplicates, so put in anything that looks like it might be needed.

## Additional packages

If we have any additional packages that have only been created for the course e.g. data packages, these will need to be hosted in our own repository.  A plain source package folder (not built or zipped) should be placed in `common_files/additional_packages/`.  A source tarball will be built from this and put in the correct place under `csama_repo`.  *Remember you'll need all the packages listed in the DESCRIPTION file (Depends, Suggests, Imports, Extends) installed on your system in order to build it successfully.*

If the package has C code or similar that needs to be compiled, we'll have to make Windows and Mac binaries.  Hopefully this doesn't happen, but see if the package author can provide them.  If not someone in the lab must have a Windows machine we can borrow.  These should be copied manually into `common_files/csama_repo/bin/macosx/contrib/3.4/` and `common_files/csama_repo/bin/windows/contrib/3.4`.

So far only the devel version `xcms` needs to be built like this, and it's already done, so hopefully nothing more is needed for this section.

## Building installation script

We can then go into the **user_installation** folder and run `create_install_script.R`.

```{bash}
cd user_installation
./create_install_script.sh
```

This first called Rscript on the file `common_files/calculateDepedencies.R`.  This processes the list of packages, builds the source versions of any additional packages, and creates `install_packages.R` which can be provided to the students as an install everything script.

The shell script then tries to **scp** the installation script to a location on the Huber group website.  Currently this is at */g/huber/www-huber/users/msmith/csama2017/* and contains both the installation script and the copy of repository containing our additional packages.

## Installation Instructions Email

There is a draft of the email to send the participants in `user_installation/InstructionsEmail.txt`.  Feel free to use any or all of it.
