/*
#Single EC2 Instance
output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = module.iac-dev-ecp.public_ip
}

output "private_ip" {
  description = "Private IP of instance"
  value       = module.iac-dev-ecp.private_ip
}

output "private_dns" {
  description = "Private DNS of instance"
  value       = module.iac-dev-ecp.private_dns
}

output "public_dns" {
  description = "Public DNS of instance (or DNS of EIP)"
  value       = module.iac-dev-ecp.public_dns
}
*/

#RDS
output "database_name" {
  value       = module.rds_cluster.database_name
  description = "Database name"
}

output "master_username" {
  value       = module.rds_cluster.master_username
  description = "Username for the master DB user"
}

output "cluster_identifier" {
  value       = module.rds_cluster.cluster_identifier
  description = "Cluster Identifier"
}

output "arn" {
  value       = module.rds_cluster.arn
  description = "Amazon Resource Name (ARN) of cluster"
}

output "endpoint" {
  value       = module.rds_cluster.endpoint
  description = "The DNS address of the RDS instance"
}

output "reader_endpoint" {
  value       = module.rds_cluster.reader_endpoint
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = module.rds_cluster.master_host
  description = "DB Master hostname"
}

output "replicas_host" {
  value       = module.rds_cluster.replicas_host
  description = "Replicas hostname"
}

output "dbi_resource_ids" {
  value       = module.rds_cluster.dbi_resource_ids
  description = "List of the region-unique, immutable identifiers for the DB instances in the cluster"
}

output "cluster_resource_id" {
  value       = module.rds_cluster.cluster_resource_id
  description = "The region-unique, immutable identifie of the cluster"
}

output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}


#ASG
output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.iac-dev-ecp.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.iac-dev-ecp.launch_template_arn
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.iac-dev-ecp.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.iac-dev-ecp.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.iac-dev-ecp.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = module.iac-dev-ecp.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = module.iac-dev-ecp.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.iac-dev-ecp.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.iac-dev-ecp.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.iac-dev-ecp.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.iac-dev-ecp.autoscaling_group_health_check_type
}

output "alb_dns_name" {
  value       = aws_elb.iac-dev-asg-elb.dns_name
  description = "The domain name of the load balancer"
}

#State File - Not applicable
// output "s3_bucket_arn" {
//   value       = aws_s3_bucket.iac-cluster-state.arn
//   description = "The ARN of the S3 bucket"
// }

// output "dynamodb_table_name" {
//   value       = aws_dynamodb_table.iac-cluster-locks.name
//   description = "The name of the DynamoDB table"
// }