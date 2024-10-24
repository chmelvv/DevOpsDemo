# VPC
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
}

# Public Subnet for EC2
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

# Private Subnet for RDS and Redis
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.10.0/24"
  availability_zone = "eu-west-1a"
}

# Additional Private Subnet for RDS and Redis
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = "eu-west-1b"
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier           = "wordpress-mysql"
  engine               = "mysql"
  engine_version       = "8.0.39"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "wordpress"
  username             = "admin"
  password             = "password"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "wordpress-redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  security_group_ids = [aws_security_group.db.id]
  subnet_group_name    = aws_elasticache_subnet_group.main.name
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name = "main"
  subnet_ids = [aws_subnet.private1.id]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("wordpress_id_rsa.pub")
}