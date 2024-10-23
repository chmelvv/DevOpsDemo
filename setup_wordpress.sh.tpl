#!/bin/bash

set -x
# Redirect stdout and stderr to a log file
exec > /var/log/setup_wordpress.log 2>&1

# Update and install necessary packages
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd wget

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Download and extract WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Install WP-CLI
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Create wp-config.php from sample
 wget -O wp-config.php https://raw.githubusercontent.com/chmelvv/abz-test/www-only/wp-config.php

# Set permissions
sudo chown -R apache:apache /var/www/html
#chmod -R 755 /var/www/html
sudo chmod 666 /var/www/html/wp-config.php

# Configure wp-config.php using WP-CLI
sudo chmod uga+w /etc/environment
echo DB_NAME=\"wordpress\" >> /etc/environment
echo  DB_USER=\"admin\" >> /etc/environment
echo DB_PASSWORD=\"password\" >> /etc/environment
echo DB_HOST=\"${rds_endpoint}\" >> /etc/environment

echo WP_REDIS_HOST=\"${redis_endpoint}\" >> /etc/environment
echo WP_REDIS_PORT=6379 >> /etc/environment
echo WP_REDIS_PREFIX=\"wordpress\" >> /etc/environment
echo WP_CACHE=true >> /etc/environment
sudo chmod uga-w /etc/environment
source /etc/environment

sudo -u apache wp config set DB_NAME "$DB_NAME"
sudo -u apache wp config set DB_USER "$DB_USER"
sudo -u apache wp config set DB_PASSWORD "$DB_PASSWORD"
sudo -u apache wp config set DB_HOST "$DB_HOST"

sudo -u apache wp config set WP_REDIS_HOST "$WP_REDIS_HOST"
sudo -u apache wp config set WP_REDIS_PORT "$WP_REDIS_PORT" --raw
sudo -u apache wp config set WP_REDIS_PREFIX "$WP_REDIS_PREFIX"
sudo -u apache wp config set WP_CACHE "$WP_CACHE" --raw

sudo -u apache  wp core install \
  --url="http://${wordpress1_public_ip}" \
  --title="ABZ WordPress" \
  --admin_user="admin" \
  --admin_password="password" \
  --admin_email="viktor.chmel@gmail.com"

sudo mkdir -p /usr/share/httpd/.wp-cli/cache/
sudo chown -R apache:apache /usr/share/httpd/.wp-cli
sudo -u apache  wp plugin install redis-cache --activate
sudo -u apache  wp redis enable

# Restart Apache to apply changes
sudo systemctl restart httpd