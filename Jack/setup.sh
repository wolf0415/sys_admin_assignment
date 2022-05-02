#!/bin/bash

# Testing if root...
if [ $UID -ne 0 ]
then
	echo "Use super user do"
	exit 1
fi

sudo apt-get install -y git
sudo apt-get install -y apache2
sudo apt-get install -y apache2-utils
sudo systemctl apache2 start
wget https://gitlab.com/wolf0415/sys_admin_assignment/-/raw/main/Jack/www/index.html
wget https://gitlab.com/wolf0415/sys_admin_assignment/-/raw/main/Jack/apache2.conf
wget https://gitlab.com/wolf0415/sys_admin_assignment/-/raw/main/Jack/inft3026.conf
wget https://gitlab.com/wolf0415/sys_admin_assignment/-/raw/main/Jack/www/test/testing.html
sudo mkdir /var/www/inft3026/
sudo mv index.html /var/www/inft3026

mkdir test/
mv testing.html test/
sudo mv test/ /var/www/inft3026/

sudo echo "Options -Indexes" > /var/www/inft3026/.htaccess
sudo chown grouphd:grouphd .htaccess

sudo htpasswd -c /etc/apache2/.htpasswd grouphd # will prompt for password

sudo mv apache2.conf /etc/apache2/apache2.conf
sudo mv inft3026.conf /etc/apache2/sites-available/
sudo a2ensite inft3026.conf
systemctl reload apache2



## Configure modsecurity 
sudo apt install libapache2-mod-security2
sudo a2enmod headers
sudo systemctl restart apache2
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
# change the value of SecRuleEngine to `on`

<<comment
# -- Rule engine initialization ----------------------------------------------

# Enable ModSecurity, attaching it to every transaction. Use detection
# only to start with, because that minimises the chances of post-installation
# disruption.
#
SecRuleEngine On
...
    

comment





sudo systemctl restart apache2

sudo rm -rf /usr/share/modsecurity-crs
sudo git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
sudo mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
sudo mv /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf


## edit /etc/apache2/mods-available/security2.conf
<<comment
<IfModule security2_module>
        SecDataDir /var/cache/modsecurity
        Include /usr/share/modsecurity-crs/crs-setup.conf
        Include /usr/share/modsecurity-crs/rules/*.conf
</IfModule>
comment



## edit inft3026.conf 
<<comment
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SecRuleEngine On
</VirtualHost>
    

comment


sudo systemctl restart apache2

## TEST IF WORKS 
curl http://<SERVER-IP/DOMAIN>/index.php?exec=/bin/bash 





