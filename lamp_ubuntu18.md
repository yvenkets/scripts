Install LAMP Server with Let’s Encrypt Free SSL on Ubuntu 18.04
 
 
 
 
 
LAMP is a free and open-source web development platform used to host dynamic and high-performance websites. It consists of four open-source components: Linux, Apache, MySQL/MariaDB, and PHP. LAMP uses Linux as the operating system, Apache for webserver, MySQL/MariaDB as a database and PHP as the scripting language.
In this tutorial, we will explain how to install LAMP and secure it with Let’s Encrypt free SSL on Ubuntu 18.04.
Prerequisites
A fresh Ubuntu 18.04 VPS on the Atlantic.Net Cloud Platform.
A valid domain name pointed to your server IP address. In this tutorial, we will use example.com as the domain.
Step 1 – Create an Atlantic.Net Cloud Server
First, log in to your Atlantic.Net Cloud Server. Create a new server, choosing Ubuntu 18.04 as the operating system, with at least 2GB RAM. Connect to your Cloud Server via SSH and log in using the credentials highlighted at the top of the page.
Once you are logged into your Ubuntu 18.04 server, run the following command to update your base system with the latest available packages.
apt-get update -y
Step 2 – Installing Apache Web Server
First, install Apache webserver with the following command:
apt-get install apache2 -y
Once the installation has been completed, start the Apache service and enable it to start after system reboot with the following command:
systemctl start apache2
systemctl enable apache2
Next, verify the Apache webserver with the following command:
systemctl status apache2
Apache web server is now running and listening on port 80. Open your web browser and type the URL http://your-server-ip. You should see the Apache default page in the following screen:

That means the Apache webserver is working as expected.
Step 3 – Installing MariaDB Database Server
MariaDB is the most popular fork of the MySQL relational database management system. You can install it by running the following command:
apt-get install mariadb-server mariadb-client -y
Once installed, start the MariaDB service and enable it to start after system reboot with the following command:
systemctl start mariadb
systemctl enable mariadb
By default, MariaDB is not secured, so you will need to secure it first. You can secure it by running the mysql_secure_installation script:
mysql_secure_installation
This script will set the root password, remove anonymous users, disallow root login remotely, and remove test database and access to it, as shown below:
Enter current password for root (enter for none): Press the Enter key
Set root password? [Y/n]: Y
New password: Enter password
Re-enter new password: Repeat password
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]:  Y
Reload privilege tables now? [Y/n]:  Y
Step 4 – Installing PHP
By default, PHP is available in the Ubuntu 18.04 default repository. You can install PHP and other libraries with the following command:
apt-get install php php-cli php-mysql php-curl php-zip libapache2-mod-php -y
Once all the packages are installed, open your php.ini file and tweak some required settings:
nano /etc/php/7.2/apache2/php.ini
Change the following lines. The below values are great settings for a LAMP environment:
memory_limit = 256M
upload_max_filesize = 100M
max_execution_time = 360
date.timezone = America/Chicago
Save and close the file. Then, restart the Apache webserver to apply the configuration.
systemctl restart apache2
Next, create a info.php in your Apache document root directory to test PHP with Apache:
nano /var/www/html/info.php
Add the following line:
<?php phpinfo( ); ?>
Save and close the file. Then, open your web browser and visit the URL http://your-server-ip/info.php. You should see the default PHP test page depicted in the following screen.

After testing, it is recommended to remove the info.php file for security reasons.
rm -rf /var/www/html/info.php
Step 5 – Creating a Virtual Host
First, create an index.html file for your domain example.com.
mkdir /var/www/html/example.com
nano /var/www/html/example.com/index.html
Add the following lines:
<html>
<title>example.com</title>
<h1>Welcome to example.com Website</h1>
<p>This is my LAMP server</p>
</html>
Save and close the file. Then, change the ownership of the example.com directory and give necessary permissions:
chown -R www-data:www-data /var/www/html/example.com
chmod -R 755 /var/www/html/example.com
Next, you will need to create an Apache virtual host configuration file for your domain, example.com.
nano /etc/apache2/sites-available/example.com.conf
Add the following lines:
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName example.com
    DocumentRoot /var/www/html/example.com
    DirectoryIndex index.html
    ErrorLog ${APACHE_LOG_DIR}/example.com_error.log
    CustomLog ${APACHE_LOG_DIR}/example.com_access.log combined
</VirtualHost>
Save and close the file when you are finished.
Here’s a brief explanation of each parameter in the above file:
ServerAdmin: Specify an email address of server admin.
ServerName: Domain name that is associated with your server IP address.
DocumentRoot: Specify the location of the content for the website.
DirectoryIndex: Specify a default page to display when a directory is accessed.
ErrorLog: Location of the error log file.
CustomLog: Location of the access log file.
Next, enable the virtual host and restart the Apache web service to apply the configuration:
a2ensite example.com
systemctl restart apache2
To test your website, open your web browser and type the URL http://example.com. You will be redirected to the following page:

Step 6 – Securing Your Website with Let’s Encrypt
At this point your website is working well, but it’s not secured. You will need to secure it with Let’s Encrypt free SSL.
First, you will need to install a Certbot client on your server. Certbot is an easy to use client that can be used to download a certificate from Let’s Encrypt and configure Apache webserver to use this certificate.
By default, the latest version of Certbot is not available in the Ubuntu 18.04 default repository. You will need to add the Certbot repository to APT.
apt-get install software-properties-common apt-transport-https ca-certificates -y
add-apt-repository ppa:certbot/certbot
Once the repository is added, update the repository and install Certbot with the following command:
apt-get update -y
apt-get install certbot python-certbot-apache -y
Next, run the following command to install Let’s Encrypt free SSL for website example.com:
certbot --apache -d example.com
You will be prompted to provide your email and agree to the terms of service, as shown below:
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): admin@example.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v02.api.letsencrypt.org/directory
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(A)gree/(C)ancel: A

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for example.com
Enabled Apache rewrite module
Waiting for verification...
Cleaning up challenges
Created an SSL vhost at /etc/apache2/sites-available/example.com-le-ssl.conf
Deploying Certificate to VirtualHost /etc/apache2/sites-available/example.com-le-ssl.conf
Enabling available site: /etc/apache2/sites-available/example.com-le-ssl.conf

Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
Next, select option 2 and hit enter to download the Let’s Encrypt certificate and configure the Apache webserver to use this certificate. Once the installation process has been completed, you should see the following output:
Enabled Apache rewrite module
Redirecting vhost in /etc/apache2/sites-enabled/example.com.conf to ssl vhost in /etc/apache2/sites-available/example.com-le-ssl.conf

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations! You have successfully enabled https://example.com

You should test your configuration at:
https://www.ssllabs.com/ssltest/analyze.html?d=example.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   Your cert will expire on 2019-10-22. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
Now, open your web browser and access your website securely with the URL https://example.com.

