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
   deployed instance,e.g.:
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
6) Also you can access WordPress admin panel by adding /wp-admin to the URL, e.g.:
```
http://<wordpress1_public_ip>/wp-admin
```
and use login/password provided in the email.
7) To destroy the infrastructure, run the following command:
```
terraform destroy
```
Installation log of WordPress instnce can be found in the file _/var/log/setup_wordpress.log_.8) 

## Configuration options
Solution configured as asked via environment variables stored in /etc/environment file on WordPress instance.
It can be changed in the _setup_wordpress.sh.tpl_ script. But to my mind it 
would be better to save them all in the root of this project in separate properties file.
