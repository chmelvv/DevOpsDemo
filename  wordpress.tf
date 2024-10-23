# EC2 Instance
resource "aws_instance" "wordpress1" {
  ami           = "ami-00385a401487aefa4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.www.id]
  key_name               = aws_key_pair.deployer.key_name
  tags = {
    Name = "WordPress1"
  }

  user_data = templatefile("setup_wordpress.sh.tpl", {
    rds_endpoint   = aws_db_instance.mysql.address,
    redis_endpoint = aws_elasticache_cluster.redis.cache_nodes[0].address,
    wordpress1_public_ip = aws_eip.wordpress1_eip.public_ip
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "wordpress1_eip" {
}

resource "aws_eip_association" "wordpress1_eip_assoc" {
  instance_id   = aws_instance.wordpress1.id
  allocation_id = aws_eip.wordpress1_eip.id
}