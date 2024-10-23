#!/bin/bash

# Redirect stdout and stderr to a log file
exec > /var/log/setup_wordpress.log 2>&1

# Update and install necessary packages
yum update -y
yum install -y httpd php php-mysqlnd wget

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and extract WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Create wp-config.php from sample
cp wp-config-sample.php wp-config.php

# Set permissions
#chown -R apache:apache /var/www/html
#chmod -R 755 /var/www/html
chmod 666 /var/www/html/wp-config.php

# Configure wp-config.php using WP-CLI
wp config set DB_NAME "wordpress"
wp config set DB_USER "admin"
wp config set DB_PASSWORD "password"
wp config set DB_HOST "$rds_endpoint"

wp config set WP_REDIS_HOST "$redis_endpoint"
wp config set WP_REDIS_PORT "6379" --raw
wp config set WP_REDIS_PREFIX "wordpress"
wp config set WP_CACHE true --raw

#wp core install --url="http://$wordpress1_endpoint" --title="ABZ WordPress" --admin_user="admin" --admin_password="password" --admin_email="viktor.chmel@gmail.com"
#wp plugin install redis-cache --activate
#wp redis enable



# Restart Apache to apply changes
systemctl restart httpd