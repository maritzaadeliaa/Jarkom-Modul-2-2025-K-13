apt-get install -y apache2-utils    htpasswd -c /etc/nginx/.htpasswd admin chmod 640 /etc/nginx/.htpasswd chown root:www-data /etc/nginx/.htpasswd

