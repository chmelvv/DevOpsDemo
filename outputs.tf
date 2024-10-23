output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "wordpress1_public_ip" {
  value =  aws_eip.wordpress1_eip.public_ip
}