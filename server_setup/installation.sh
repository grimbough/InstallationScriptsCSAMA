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

## install R
sudo echo 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/' >> /etc/apt/sources.list.d/additional-repositories.list



## share internet connection
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -A FORWARD -o wlp4s0 -i enx0050b61fb9aa -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -o wlp4s0 -j MASQUERADE

sudo iptables -I FORWARD -o wlp4s0 -s 192.168.0.0/24 -j ACCEPT
sudo iptables -I INPUT -s 192.168.0.0/24 -j ACCEPT


## clean IPTABLES

sudo iptables --policy INPUT ACCEPT;
sudo iptables --policy OUTPUT ACCEPT;
sudo iptables --policy FORWARD ACCEPT;

sudo iptables -Z;
sudo iptables -F;
sudo iptables -X;

