sudo apt-get install build-essential lighttpd

## configuring webserver

mkdir $HOME/public_html
sudo sed --in-place=.bak 's/\/var\/www\/html/\/home\/csama\/public_html/g' /etc/lighttpd/lighttpd.conf
sudo service lighttpd restart
