REPO_HOME=$HOME/github/InstallationScriptsCSAMA

sudo apt-get install build-essential lighttpd

#################
## configuring webserver
#################
mkdir $HOME/public_html
sudo sed --in-place=.bak 's/\/var\/www\/html/\/home\/csama\/public_html/g' /etc/lighttpd/lighttpd.conf
sudo service lighttpd restart

##################
## CRAN & BioC Mirror
##################

mkdir $HOME/R_packages
ln -s $HOME/R_packages $HOME/public_html/packages

## download Bioc packages
cd /tmp/
$REPO_HOME/server_setup/wget_repositories.sh

## download CRAN - edit rsync_repositores.sh to remove --dry-run
cd $HOME/R_packages
ln -sf $REPO_HOME/server_setup/rsync.include .
$REPO_HOME/server_setup/rsync_repositories.sh
