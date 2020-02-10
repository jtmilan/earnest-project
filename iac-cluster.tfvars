#label
namespace          = "iac"

stage              = "dev"

name               = "ecp"

#vpc
region             = "us-west-2"

availability_zones = ["us-west-2a","us-west-2b", "us-west-2c"]

cidr               = "10.0.0.0/16"

#ec2
ami                = "ami-0d1cd67c26f5fca19"

ami_owner          = "099720109477"

instance           = "t2.micro"

allowed_ports      = [22, 80, 8080, 443]


#keypair
ssh_name           = "jeffrymilan"

ssh_public_key_path = "./secrets"

generate_ssh_key   = true

ssh_key_pair       = "keypair"

associate_public_ip_address = true

welcome_message    = "Welcome to Control Server"

#RDS
rds_name = "rds"

instance_type = "db.r4.large"

cluster_family = "aurora-postgresql10"

cluster_size = 1

rds_allowed_ports  = [8080, 5432]

engine = "aurora-postgresql"

engine_mode = "11.6"

db_name = "iac_db"

admin_user = "adminrds"

admin_password = "passw0rd"


#ASG
asg_name = "ec2-asg"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 2

min_size = 1

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20
