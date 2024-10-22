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

# Public Subnet for EC2
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
}

# Private Subnet for RDS and Redis
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "eu-west-1a"
}

# Security Group for EC2
resource "aws_security_group" "www" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS and Redis
resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.www.id]
  }

  ingress {
    description = "Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.www.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier           = "wordpress-mysql"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  db_name              = "wordpress"
  username             = "admin"
  password             = "password"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "wordpress-redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  security_group_ids = [aws_security_group.db.id]
  subnet_group_name    = aws_elasticache_subnet_group.main.name
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name = "main"
  subnet_ids = [aws_subnet.private.id]
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name = "main"
  subnet_ids = [aws_subnet.private.id]
}