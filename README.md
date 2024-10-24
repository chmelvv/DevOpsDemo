## How to run project
1) To clone this project to you local machine, run the following command:
```
git clone https://github.com/chmelvv/abz-test.git
```
2) Setup your AWS credentials for aws cli to be able to run the _terraform_ command.
3) To deploy the infrastructure, run the following command:
```
terraform deploy
```
4) After the script finishes, it will output some hostname and IP address of the
   deployed instance, e.g.
```
rds_endpoint = "wordpress-mysql.c3ackwi4garm.eu-west-1.rds.amazonaws.com"
redis_endpoint = "wordpress-redis.kjtjv1.0001.euw1.cache.amazonaws.com"
wordpress1_public_ip = "52.209.60.128"
```
5) To check the WordPress website: open the browser and enter the IP address of the _wordpress1_public_ip_
   in the address bar.
You can connect by ssh to that instance by command 
```
ssh -i wordpress_id_rsa ec2-user@<wordpress1_public_ip>
```
6) Also, you can access WordPress admin panel by adding /wp-admin to the URL, e.g.:
```
http://<wordpress1_public_ip>/wp-admin
```
and use login/password provided in the email.

7) To destroy the infrastructure, run the following command:
```
terraform destroy
```
8) Installation log of WordPress instance can be found in the file _/var/log/setup_wordpress.log_. 

## Configuration options
Solution configured as asked via environment variables stored in /etc/environment file on WordPress instance.
It can be changed in the _setup_wordpress.sh.tpl_ script. 

To my mind it would be better to save them all in the root of this project in separate properties file, but it is as it is.

## Code structure
The code is structured as follows:
- main.tf - main Terraform configuration file containing VPC, subnets, security groups, RDS, ElastiCache and EC2 instance resources.
- outputs.tf - to publish the outputs of the Terraform configuration.
- security_groups.tf - contains the security groups for the EC2 instance and RDS.
- routes.tf - contains the route table and route table association resources.
- wordpress.tf - contains the EC2 instance resource for WordPress WWW server.
    It uses the userdata template script to install and configure the WordPress.
- setup_wordpress.sh.tpl - template script to install and configure WordPress on the EC2 instance.
- wordpress_id_rsa - private key to connect to the EC2 instance via SSH if needed.
- wp-config.php.tpl - comfig file for WordPress as you asked. Configured during deployment.


