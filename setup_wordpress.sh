#!/bin/bash

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

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Create wp-config.php from sample
cp wp-config-sample.php wp-config.php

wp plugin install redis-cache --activate
wp redis enable

# Set environment variables for database and Redis
DB_NAME=wordpress
DB_USER=admin
DB_PASSWORD=password
DB_HOST=$rds_endpoint

REDIS_HOST=$redis_endpoint
REDIS_PORT=6379

# Configure wp-config.php using WP-CLI
wp config set DB_NAME "$DB_NAME"
wp config set DB_USER "$DB_USER"
wp config set DB_PASSWORD "$DB_PASSWORD"
wp config set DB_HOST "$DB_HOST"
wp config set WP_REDIS_HOST "$REDIS_HOST"
wp config set WP_REDIS_PORT "$REDIS_PORT" --raw
wp config set WP_CACHE_KEY_SALT 'wordpress:' --raw
wp config set WP_CACHE true --raw

# Restart Apache to apply changes
systemctl restart httpd