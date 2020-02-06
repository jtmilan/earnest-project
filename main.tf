#############
# Cloud Provider 
#############
provider "aws"{
  region             = var.region

  # Make it faster by skipping some checks
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

#############
# VPC 
#############
module "vpc" {
  source             = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  cidr_block         = var.cidr

  tags = {
      Name  = "iac-dev-vpc"
      Owner  = "Terraform"
  }
}

##############
# Subnet 
#############
module "subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = var.cidr
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags = {
      Name  = "iac-dev-subnet"
  }
}

#############
# KeyPair 
#############
module "aws_key_pair" {
  source               = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.ssh_name
  ssh_public_key_path  = var.ssh_public_key_path
  generate_ssh_key     = var.generate_ssh_key

  tags = {
      Name  = "iac-dev-keypair"
      Owner  = "Terraform"
  }
}


#############
# EC2 AutoScale Group
#############
module "iac-dev-ecp" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master"

  namespace                   = var.namespace
  stage                       = var.stage
  name                        = var.asg_name
  

  image_id                    = var.ami
  instance_type               = var.instance
  // subnet_ids                  = module.subnets.public_subnet_ids
  subnet_ids                  = module.subnets.private_subnet_ids
  health_check_type           = var.health_check_type
  min_size                    = var.min_size
  max_size                    = var.max_size
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  key_name                    = module.aws_key_pair.key_name
  security_group_ids          = [aws_security_group.iac-dev-ec2-sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  load_balancers              = [aws_elb.iac-dev-asg-elb.name]
  user_data_base64            = base64encode(data.template_file.user_data.rendered)
  #user_data 		       = data.template_file.rds.rendered # this can be used to load dynamic values into userdata script
  
  tags               = {
      Tier   = "1"
      Name   = "iac-dev-ec2"
      Owner  = "Terraform"
  }
  
  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

}

data "template_file" "user_data" {
  template = file("./user-data/user-data.sh")

  vars = {
    user_data        = <<-EOF
                      #!/bin/bash
                      apt-get update
                      apt -y install nginx
                      apt -y install docker.io
                      ufw allow 'Nginx HTTP'
                      systemctl start docker
                      systemctl enable docker
                      docker run --name iac-nginx --restart=unless-stopped -v /opt/iac:/usr/share/nginx/html:ro -d -p 8080:80 nginx
                      EOF

    welcome_message  = var.welcome_message
    db_endpoint      = module.rds_cluster.endpoint
    db_name          = module.rds_cluster.database_name
  }

}

#############
# RDS Aurora
#############
module "rds_cluster" {
  source              = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.rds_name
  engine              = var.engine
  cluster_family      = var.cluster_family
  cluster_size        = var.cluster_size
  admin_user          = var.admin_user
  admin_password      = var.admin_password
  db_name             = var.db_name
  instance_type       = var.instance_type
  vpc_id              = module.vpc.vpc_id
  subnets             = module.subnets.private_subnet_ids
  security_groups     = [aws_security_group.iac-dev-rds-sg.id]
  // security_groups     = [module.vpc.vpc_default_security_group_id]
}


#############
# EC2  Single Instance
#############
/*
module "iac-dev-ecp" {
  source               = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=master"
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  ami                  = var.ami
  ami_owner            = var.ami_owner
  ssh_key_pair         = module.aws_key_pair.key_name
  vpc_id               = module.vpc.vpc_id
  subnet               = module.subnets.private_subnet_ids[0]
  security_groups      = [aws_security_group.iac-dev-ec2-sg.id]
  // security_groups             = [module.vpc.vpc_default_security_group_id]
  // assign_eip_address          = var.assign_eip_address
  associate_public_ip_address = var.associate_public_ip_address
  instance_type        = var.instance
  allowed_ports        = var.allowed_ports
  user_data            = data.template_file.user_data.rendered
  #user_data 		       = data.template_file.rds.rendered # this can be used to load dynamic values into userdata script
  tags               = {
      Name   = "iac-dev-ec2"
      Owner  = "Terraform"
  }
}

data "template_file" "user_data" {
  template = file("./user-data/user-data.sh")

  vars = {
    user_data        = <<-EOF
                      #!/bin/bash
                      apt-get update
                      apt -y install nginx
                      apt -y install docker.io
                      ufw allow 'Nginx HTTP'
                      systemctl start docker
                      systemctl enable docker
                      docker run --name iac-nginx --restart=unless-stopped -v /opt/iac:/usr/share/nginx/html:ro -d -p 8080:80 nginx
                      EOF

    welcome_message  = var.welcome_message
    db_endpoint      = module.rds_cluster.endpoint
    db_name          = module.rds_cluster.database_name
  }

}
*/
