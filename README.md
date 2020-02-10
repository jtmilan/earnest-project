
<!-- ![Earnest](https://imgur.com/0mZDs6m.png) -->

> # **Web App Demo**

- **Prepared By:** Jeffry Milan
- **Demo On:** Feb 06, 2020

> <i class="fa fa-tags" aria-hidden="true"></i>tags: `rds` `nginx` `elb` `terraform` `aws`


# Earnest Requirements:
Please configure the following test environment in AWS Region -
**us-west-2 (Oregon)**

-  VPC with 3 public and 3 private subnets - 1 public subnet and 1 private subnet per availability zone
-  1 EC2 instance running Ubuntu (Fully patched LTS, t2.micro) in a private subnet 
-  1 ELB/ALB forwarding traffic to the EC2 instance 
-  Setup Docker daemon on this instance 
-  Create the following stack
- 
	-- EC2 instance running a docker nginx container ○ RDS Instance - 	postgres (t2.micro)  
	-- ELB to route traffic the ec2 instance  
	-- Security groups for various resources

# Project Description:
The environment specified is a naive representation of a web application with a database backend. You have Systems, Database and Network admin access to the complete AWS account - do let us know if you run into any access problems. Please document your work and include any scripts/automation (tar archive) you used when you submit your findings as a text document (markdown, PDF, plain text).


# Architectural Diagram:

This will create an  Web App cluster, made up of a set of three nodes in an auto-scaling group across the three availability zones specified. The screenshot below shows this cluster with a single service running in it:


![Architecture Diagram](https://imgur.com/fSAxQIO.jpg)

# Terraform Diagram
```shell
$ terraform  graph  | grep -v -E "meta|module|output|var|null"
```

```groovy=
Output: 

digraph {
        compound = "true"
        newrank = "true"
        subgraph "root" {
                "[root] aws_dynamodb_table.iac-cluster-locks" [label = "aws_dynamodb_table.iac-cluster-locks", shape = "box"]
                "[root] aws_elb.iac-dev-asg-elb" [label = "aws_elb.iac-dev-asg-elb", shape = "box"]
                "[root] aws_s3_bucket.iac-cluster-state" [label = "aws_s3_bucket.iac-cluster-state", shape = "box"]
                "[root] aws_security_group.iac-dev-ec2-sg" [label = "aws_security_group.iac-dev-ec2-sg", shape = "box"]
                "[root] aws_security_group.iac-dev-rds-sg" [label = "aws_security_group.iac-dev-rds-sg", shape = "box"]
                "[root] aws_security_group_rule.egress" [label = "aws_security_group_rule.egress", shape = "box"]
                "[root] aws_security_group_rule.ingress" [label = "aws_security_group_rule.ingress", shape = "box"]
                "[root] aws_security_group_rule.rds_egress" [label = "aws_security_group_rule.rds_egress", shape = "box"]
                "[root] aws_security_group_rule.rds_ingress" [label = "aws_security_group_rule.rds_ingress", shape = "box"]
                "[root] aws_security_group_rule.rds_ingress_dynamic" [label = "aws_security_group_rule.rds_ingress_dynamic", shape = "box"]
                "[root] data.template_file.rds" [label = "data.template_file.rds", shape = "box"]
                "[root] data.template_file.user_data" [label = "data.template_file.user_data", shape = "box"]
                "[root] provider.aws" [label = "provider.aws", shape = "diamond"]
                "[root] provider.template" [label = "provider.template", shape = "diamond"]
                "[root] aws_dynamodb_table.iac-cluster-locks" -> "[root] provider.aws"
                "[root] aws_elb.iac-dev-asg-elb" -> "[root] aws_security_group.iac-dev-ec2-sg"
                "[root] aws_s3_bucket.iac-cluster-state" -> "[root] provider.aws"
                "[root] aws_security_group_rule.egress" -> "[root] aws_security_group.iac-dev-ec2-sg"
                "[root] aws_security_group_rule.ingress" -> "[root] aws_security_group.iac-dev-ec2-sg"
                "[root] aws_security_group_rule.rds_egress" -> "[root] aws_security_group.iac-dev-rds-sg"
                "[root] aws_security_group_rule.rds_ingress" -> "[root] aws_security_group.iac-dev-rds-sg"
                "[root] aws_security_group_rule.rds_ingress_dynamic" -> "[root] aws_security_group.iac-dev-rds-sg"
                "[root] data.template_file.rds" -> "[root] provider.template"
                "[root] data.template_file.user_data" -> "[root] provider.template"
                "[root] provider.aws (close)" -> "[root] aws_dynamodb_table.iac-cluster-locks"
                "[root] provider.aws (close)" -> "[root] aws_s3_bucket.iac-cluster-state"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.egress"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.ingress"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.rds_egress"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.rds_ingress"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.rds_ingress_dynamic"
                "[root] provider.template (close)" -> "[root] data.template_file.rds"
                "[root] provider.template (close)" -> "[root] data.template_file.user_data"
                "[root] root" -> "[root] provider.aws (close)"
                "[root] root" -> "[root] provider.local (close)"
                "[root] root" -> "[root] provider.template (close)"
                "[root] root" -> "[root] provider.tls (close)"
                "[root] root" -> "[root] provisioner.local-exec (close)"
        }
}
```

![Architecture Diagram](https://imgur.com/8YPhu9T.png)

# Technology Used:
Creating stacks in **AWS** makes it simple by deploying using **Terraform**. 
**Terraform** is an open source tool created by **HashiCorp** [https://www.terraform.io/](https://www.terraform.io) and written in the **Go programming language**. The Go code compiles down into a single binary (or rather, one binary for each of the supported operating systems) called, not surprisingly, `terraform`. 

# IAC(Infrastructure as a Code) 

There are five broad  categories of IAC tools:

-   Ad hoc scripts
-   Configuration management tools
-   Server templating tools
-   Orchestration tools
-   Provisioning tools

Because Terraform supports many different cloud providers, a common question that arises is whether it supports  _transparent portability_  between them.  

Terraform’s approach is to allow you to write code that is specific to each provider, taking advantage of that provider’s unique functionality, but to use the same language, toolset, and IaC practices under the hood for all providers.


# VPC Design

1. Evenly divide your address space across as many AZ’s as possible.
2. Determine the different kinds of routing you’ll need and the relative number of hosts for each kind.
3. Create identically-sized subnets in each AZ for each routing need. Give them the same route table.
4. Leave yourself unallocated space in case you missed something.

```    
        19-bit: 8190 addresses per AZ

        10.0.0.0/16:
            10.0.0.0/18 — AZ A
                10.0.0.0/19 — Private
                10.0.32.0/19
                    10.0.32.0/20 — Public
                    10.0.48.0/20
                        10.0.48.0/21 — Protected
                        10.0.56.0/21 — Spare
```



# Quick Start
Terraform 0.11 or greater is required. The most simple configuration is below (the values used for the variables are actually the defaults, so could be omitted):

```shell
terraform {
  required_version = "~> 0.12.0"

  required_providers {
    aws      = "~> 2.0"
    template = "~> 2.0"
    local    = "~> 1.2"
    null     = "~> 2.0"
  }
}

```

## Prerequisites 

AWS CLI configured required IAM access.
```shell
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)

```

Terraform Installed on your local workstation.
```shell
On MAC: 
Terminal: $brew install terraform

Windows: 
https://learn.hashicorp.com/terraform/getting-started/install.html
```


### Terraform Automation - HA contanerized nginx webserver setup and RDS Aurora cluster.

### Resources created by this template.
* This creates a new `VPC` in us-west-2 (Oregon region) with 3 `public subnets` and `private subnet`
* AWS autoscaling group with min-max 1 instances for testing HA across availability zones.
* This also creates separate security_groups for `instances` and `ELB`. 
* This also creates the ELB and register it with ASG instances.
* nginx docker container is created - part of `user_data` script supplied to each instance belong to ASG.
* We are also creating RDS Postgresql Aurora cluster.

### Clone repository
```shell
$ git clone https://github.com/jtmilan/earnest-project.git
cd earnest-project
```

## Setup 

### Initialize terraform

```shell
#with state
$ terraform init -backend-config=backend.hcl

#without state - Please use this one
$ terraform init
```


```shell
Initializing modules...
Downloading git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master for aws_key_pair...
- aws_key_pair in .terraform/modules/aws_key_pair
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0 for aws_key_pair.label...
- aws_key_pair.label in .terraform/modules/aws_key_pair.label
Downloading git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master for iac-dev-ecp...
- iac-dev-ecp in .terraform/modules/iac-dev-ecp
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0 for iac-dev-ecp.label...
- iac-dev-ecp.label in .terraform/modules/iac-dev-ecp.label
Downloading git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=master for rds_cluster...
- rds_cluster in .terraform/modules/rds_cluster
Downloading git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.3.0 for rds_cluster.dns_master...
- rds_cluster.dns_master in .terraform/modules/rds_cluster.dns_master
Downloading git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.3.0 for rds_cluster.dns_replicas...
- rds_cluster.dns_replicas in .terraform/modules/rds_cluster.dns_replicas
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0 for rds_cluster.label...
- rds_cluster.label in .terraform/modules/rds_cluster.label
Downloading git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master for subnets...
- subnets in .terraform/modules/subnets
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for subnets.label...
- subnets.label in .terraform/modules/subnets.label
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for subnets.nat_instance_label...
- subnets.nat_instance_label in .terraform/modules/subnets.nat_instance_label
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for subnets.nat_label...
- subnets.nat_label in .terraform/modules/subnets.nat_label
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for subnets.private_label...
- subnets.private_label in .terraform/modules/subnets.private_label
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for subnets.public_label...
- subnets.public_label in .terraform/modules/subnets.public_label
Downloading git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master for vpc...
- vpc in .terraform/modules/vpc
Downloading git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.0 for vpc.label...
- vpc.label in .terraform/modules/vpc.label

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "tls" (hashicorp/tls) 2.1.1...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...
- Downloading plugin for provider "template" (hashicorp/template) 2.1.2...
- Downloading plugin for provider "local" (hashicorp/local) 1.4.0...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.48.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Terraform Plan (dry-run)

```shell
$ terraform plan -var-file=iac-cluster.tfvars -out=./plan/iac-cluster.plan
```

```yaml

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.data.aws_availability_zones.available: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.template_file.rds will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "rds"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<~EOT
            #!/bin/bash -xe
            
            sudo apt-get update -y 
            
            # install docker
            sudo curl https://releases.rancher.com/install-docker/17.03.sh | sh
            sudo usermod -a -G docker admin
            
            # Run wordpress container that connects with RDS cluster.
            sudo docker run --name iac-wordpress -e WORDPRESS_DB_HOST="${rds_endpoint}" -e WORDPRESS_DB_USER=rdsuser -e WORDPRESS_DB_PASSWORD=rdspassword -d wordpress
        EOT
      + vars     = {
          + "rds_endpoint" = (known after apply)
          + "rds_user"     = "adminrds"
        }
    }

  # data.template_file.user_data will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "user_data"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<~EOT
            #!/usr/bin/env bash
            
            if [ "$(. /etc/os-release; echo $NAME)" = "Ubuntu" ]; then
              apt-get update
              apt-get -y install figlet
              SSH_USER=ubuntu
            else
              yum install epel-release -y
              yum install figlet -y
              SSH_USER=ec2-user
            fi
            # Generate system banner
            figlet "${welcome_message}" > /etc/motd
            
            
            ##
            ## Setup SSH Config
            ##
            cat <<"__EOF__" > /home/SSH_USER/.ssh/config
            Host *
                StrictHostKeyChecking no
            __EOF__
            chmod 600 /home/$SSH_USER/.ssh/config
            chown $SSH_USER:$SSH_USER /home/SSH_USER/.ssh/config
            
            ##
            ## Setup HTML
            ##
            sudo mkdir -p /opt/iac
            sudo chown -R admin.admin /opt/iac
            cat <<"__EOF__" > /opt/iac/index.html
            <h1>Database Info: </h1>
            <p><strong>PostgreSQL Endoint:</strong> ${db_endpoint}</p>
            <p><strong>PostgreSQL Instance:</strong> ${db_name}</p>
            
            <footer>
              <p><strong>Posted by:</strong> Jeffry Milan</p>
              <p><strong>Contact information:</strong> <a href="mailto:jeffry.milan@gmail.com">jtmilan@gmail.com</a>.</p>
            </footer>
            <p><strong>Note:</strong> The environment specified is a naive representation of a web application with a database backend.</p>
            __EOF__
            
            ${user_data}
        EOT
      + vars     = {
          + "db_endpoint"     = (known after apply)
          + "db_name"         = "iac_db"
          + "user_data"       = <<~EOT
                #!/bin/bash
                apt-get update
                apt -y install nginx
                apt -y install docker.io
                ufw allow 'Nginx HTTP'
                systemctl start docker
                systemctl enable docker
                docker run --name iac-nginx --restart=unless-stopped -v /opt/iac:/usr/share/nginx/html:ro -d -p 8080:80 nginx
            EOT
          + "welcome_message" = "Welcome to Control Server"
        }
    }

  # aws_elb.iac-dev-asg-elb will be created
  + resource "aws_elb" "iac-dev-asg-elb" {
      + arn                         = (known after apply)
      + availability_zones          = (known after apply)
      + connection_draining         = true
      + connection_draining_timeout = 400
      + cross_zone_load_balancing   = true
      + dns_name                    = (known after apply)
      + id                          = (known after apply)
      + idle_timeout                = 400
      + instances                   = (known after apply)
      + internal                    = (known after apply)
      + name                        = "iac-dev-asg-elb"
      + security_groups             = (known after apply)
      + source_security_group       = (known after apply)
      + source_security_group_id    = (known after apply)
      + subnets                     = (known after apply)
      + zone_id                     = (known after apply)

      + health_check {
          + healthy_threshold   = (known after apply)
          + interval            = (known after apply)
          + target              = (known after apply)
          + timeout             = (known after apply)
          + unhealthy_threshold = (known after apply)
        }

      + listener {
          + instance_port     = 8080
          + instance_protocol = "tcp"
          + lb_port           = 80
          + lb_protocol       = "tcp"
        }
    }

  # aws_security_group.iac-dev-ec2-sg will be created
  + resource "aws_security_group" "iac-dev-ec2-sg" {
      + arn                    = (known after apply)
      + description            = "security group for ec2 instance"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "iac-dev-ec2-sg"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name"  = "iac-dev-ec2-sg"
          + "Owner" = "Terraform"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.iac-dev-rds-sg will be created
  + resource "aws_security_group" "iac-dev-rds-sg" {
      + arn                    = (known after apply)
      + description            = "security group for rds instances"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "iac-dev-rds-sg"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name"  = "iac-dev-rds-sg"
          + "Owner" = "Terraform"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.egress[0] will be created
  + resource "aws_security_group_rule" "egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 65535
      + type                     = "egress"
    }

  # aws_security_group_rule.ingress[0] will be created
  + resource "aws_security_group_rule" "ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 22
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_security_group_rule.ingress[1] will be created
  + resource "aws_security_group_rule" "ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 80
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 80
      + type                     = "ingress"
    }

  # aws_security_group_rule.ingress[2] will be created
  + resource "aws_security_group_rule" "ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 8080
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 8080
      + type                     = "ingress"
    }

  # aws_security_group_rule.ingress[3] will be created
  + resource "aws_security_group_rule" "ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 443
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

  # aws_security_group_rule.rds_egress[0] will be created
  + resource "aws_security_group_rule" "rds_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.rds_ingress[0] will be created
  + resource "aws_security_group_rule" "rds_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 8080
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 8080
      + type                     = "ingress"
    }

  # aws_security_group_rule.rds_ingress[1] will be created
  + resource "aws_security_group_rule" "rds_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 5432
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 5432
      + type                     = "ingress"
    }

  # aws_security_group_rule.rds_ingress_dynamic[0] will be created
  + resource "aws_security_group_rule" "rds_ingress_dynamic" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 65535
      + type                     = "ingress"
    }

  # module.aws_key_pair.aws_key_pair.generated[0] will be created
  + resource "aws_key_pair" "generated" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "iac-dev-jeffrymilan"
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
    }

  # module.aws_key_pair.local_file.private_key_pem[0] will be created
  + resource "local_file" "private_key_pem" {
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./secrets/iac-dev-jeffrymilan"
      + id                   = (known after apply)
      + sensitive_content    = (sensitive value)
    }

  # module.aws_key_pair.local_file.public_key_openssh[0] will be created
  + resource "local_file" "public_key_openssh" {
      + content              = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./secrets/iac-dev-jeffrymilan.pub"
      + id                   = (known after apply)
    }

  # module.aws_key_pair.null_resource.chmod[0] will be created
  + resource "null_resource" "chmod" {
      + id       = (known after apply)
      + triggers = {
          + "local_file_private_key_pem" = "local_file.private_key_pem"
        }
    }

  # module.aws_key_pair.tls_private_key.default[0] will be created
  + resource "tls_private_key" "default" {
      + algorithm                  = "RSA"
      + ecdsa_curve                = "P224"
      + id                         = (known after apply)
      + private_key_pem            = (sensitive value)
      + public_key_fingerprint_md5 = (known after apply)
      + public_key_openssh         = (known after apply)
      + public_key_pem             = (known after apply)
      + rsa_bits                   = 2048
    }

  # module.iac-dev-ecp.aws_autoscaling_group.default[0] will be created
  + resource "aws_autoscaling_group" "default" {
      + arn                       = (known after apply)
      + availability_zones        = (known after apply)
      + default_cooldown          = 300
      + desired_capacity          = (known after apply)
      + enabled_metrics           = [
          + "GroupDesiredCapacity",
          + "GroupInServiceInstances",
          + "GroupMaxSize",
          + "GroupMinSize",
          + "GroupPendingInstances",
          + "GroupStandbyInstances",
          + "GroupTerminatingInstances",
          + "GroupTotalInstances",
        ]
      + force_delete              = false
      + health_check_grace_period = 300
      + health_check_type         = "EC2"
      + id                        = (known after apply)
      + load_balancers            = [
          + "iac-dev-asg-elb",
        ]
      + max_size                  = 2
      + metrics_granularity       = "1Minute"
      + min_elb_capacity          = 0
      + min_size                  = 1
      + name                      = (known after apply)
      + name_prefix               = "iac-dev-ec2-asg-"
      + protect_from_scale_in     = false
      + service_linked_role_arn   = (known after apply)
      + tags                      = [
          + {
              + "key"                 = "Name"
              + "propagate_at_launch" = "true"
              + "value"               = "iac-dev-ec2"
            },
          + {
              + "key"                 = "Namespace"
              + "propagate_at_launch" = "true"
              + "value"               = "iac"
            },
          + {
              + "key"                 = "Owner"
              + "propagate_at_launch" = "true"
              + "value"               = "Terraform"
            },
          + {
              + "key"                 = "Stage"
              + "propagate_at_launch" = "true"
              + "value"               = "dev"
            },
          + {
              + "key"                 = "Tier"
              + "propagate_at_launch" = "true"
              + "value"               = "1"
            },
        ]
      + target_group_arns         = (known after apply)
      + termination_policies      = [
          + "Default",
        ]
      + vpc_zone_identifier       = (known after apply)
      + wait_for_capacity_timeout = "10m"
      + wait_for_elb_capacity     = 0

      + launch_template {
          + id      = (known after apply)
          + name    = (known after apply)
          + version = "$Latest"
        }
    }

  # module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0] will be created
  + resource "aws_autoscaling_policy" "scale_down" {
      + adjustment_type         = "ChangeInCapacity"
      + arn                     = (known after apply)
      + autoscaling_group_name  = (known after apply)
      + cooldown                = 300
      + id                      = (known after apply)
      + metric_aggregation_type = (known after apply)
      + name                    = "iac-dev-ec2-asg-scale-down"
      + policy_type             = "SimpleScaling"
      + scaling_adjustment      = -1
    }

  # module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0] will be created
  + resource "aws_autoscaling_policy" "scale_up" {
      + adjustment_type         = "ChangeInCapacity"
      + arn                     = (known after apply)
      + autoscaling_group_name  = (known after apply)
      + cooldown                = 300
      + id                      = (known after apply)
      + metric_aggregation_type = (known after apply)
      + name                    = "iac-dev-ec2-asg-scale-up"
      + policy_type             = "SimpleScaling"
      + scaling_adjustment      = 1
    }

  # module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "cpu_high" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_description                     = "Scale up if CPU utilization is above 80 for 300 seconds"
      + alarm_name                            = "iac-dev-ec2-asg-cpu-utilization-high"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 2
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + threshold                             = 80
      + treat_missing_data                    = "missing"
    }

  # module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "cpu_low" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_description                     = "Scale down if the CPU utilization is below 20 for 300 seconds"
      + alarm_name                            = "iac-dev-ec2-asg-cpu-utilization-low"
      + arn                                   = (known after apply)
      + comparison_operator                   = "LessThanOrEqualToThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 2
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + threshold                             = 20
      + treat_missing_data                    = "missing"
    }

  # module.iac-dev-ecp.aws_launch_template.default[0] will be created
  + resource "aws_launch_template" "default" {
      + arn                                  = (known after apply)
      + default_version                      = (known after apply)
      + disable_api_termination              = false
      + ebs_optimized                        = "false"
      + id                                   = (known after apply)
      + image_id                             = "ami-0d1cd67c26f5fca19"
      + instance_initiated_shutdown_behavior = "terminate"
      + instance_type                        = "t2.micro"
      + key_name                             = "iac-dev-jeffrymilan"
      + latest_version                       = (known after apply)
      + name                                 = (known after apply)
      + name_prefix                          = "iac-dev-ec2-asg-"
      + tags                                 = {
          + "Name"      = "iac-dev-ec2"
          + "Namespace" = "iac"
          + "Owner"     = "Terraform"
          + "Stage"     = "dev"
          + "Tier"      = "1"
        }
      + user_data                            = (known after apply)

      + iam_instance_profile {}

      + monitoring {
          + enabled = true
        }

      + network_interfaces {
          + associate_public_ip_address = "true"
          + delete_on_termination       = true
          + description                 = "iac-dev-ec2-asg"
          + device_index                = 0
          + security_groups             = (known after apply)
        }

      + tag_specifications {
          + resource_type = "volume"
          + tags          = {
              + "Name"      = "iac-dev-ec2"
              + "Namespace" = "iac"
              + "Owner"     = "Terraform"
              + "Stage"     = "dev"
              + "Tier"      = "1"
            }
        }
      + tag_specifications {
          + resource_type = "instance"
          + tags          = {
              + "Name"      = "iac-dev-ec2"
              + "Namespace" = "iac"
              + "Owner"     = "Terraform"
              + "Stage"     = "dev"
              + "Tier"      = "1"
            }
        }
    }

  # module.rds_cluster.aws_db_parameter_group.default[0] will be created
  + resource "aws_db_parameter_group" "default" {
      + arn         = (known after apply)
      + description = "DB instance parameter group"
      + family      = "aurora-postgresql10"
      + id          = (known after apply)
      + name        = "iac-dev-rds"
      + name_prefix = (known after apply)
      + tags        = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
    }

  # module.rds_cluster.aws_db_subnet_group.default[0] will be created
  + resource "aws_db_subnet_group" "default" {
      + arn         = (known after apply)
      + description = "Allowed subnets for DB cluster instances"
      + id          = (known after apply)
      + name        = "iac-dev-rds"
      + name_prefix = (known after apply)
      + subnet_ids  = (known after apply)
      + tags        = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
    }

  # module.rds_cluster.aws_rds_cluster.default[0] will be created
  + resource "aws_rds_cluster" "default" {
      + apply_immediately                   = true
      + arn                                 = (known after apply)
      + availability_zones                  = (known after apply)
      + backtrack_window                    = 0
      + backup_retention_period             = 5
      + cluster_identifier                  = "iac-dev-rds"
      + cluster_identifier_prefix           = (known after apply)
      + cluster_members                     = (known after apply)
      + cluster_resource_id                 = (known after apply)
      + copy_tags_to_snapshot               = false
      + database_name                       = "iac_db"
      + db_cluster_parameter_group_name     = "iac-dev-rds"
      + db_subnet_group_name                = "iac-dev-rds"
      + deletion_protection                 = false
      + enable_http_endpoint                = false
      + enabled_cloudwatch_logs_exports     = []
      + endpoint                            = (known after apply)
      + engine                              = "aurora-postgresql"
      + engine_mode                         = "provisioned"
      + engine_version                      = (known after apply)
      + final_snapshot_identifier           = "iac-dev-rds"
      + hosted_zone_id                      = (known after apply)
      + iam_database_authentication_enabled = false
      + id                                  = (known after apply)
      + kms_key_id                          = (known after apply)
      + master_password                     = (sensitive value)
      + master_username                     = "adminrds"
      + port                                = (known after apply)
      + preferred_backup_window             = "07:00-09:00"
      + preferred_maintenance_window        = "wed:03:00-wed:04:00"
      + reader_endpoint                     = (known after apply)
      + skip_final_snapshot                 = true
      + storage_encrypted                   = false
      + tags                                = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
      + vpc_security_group_ids              = (known after apply)
    }

  # module.rds_cluster.aws_rds_cluster_instance.default[0] will be created
  + resource "aws_rds_cluster_instance" "default" {
      + apply_immediately               = (known after apply)
      + arn                             = (known after apply)
      + auto_minor_version_upgrade      = true
      + availability_zone               = (known after apply)
      + ca_cert_identifier              = (known after apply)
      + cluster_identifier              = (known after apply)
      + copy_tags_to_snapshot           = false
      + db_parameter_group_name         = "iac-dev-rds"
      + db_subnet_group_name            = "iac-dev-rds"
      + dbi_resource_id                 = (known after apply)
      + endpoint                        = (known after apply)
      + engine                          = "aurora-postgresql"
      + engine_version                  = (known after apply)
      + id                              = (known after apply)
      + identifier                      = "iac-dev-rds-1"
      + identifier_prefix               = (known after apply)
      + instance_class                  = "db.r4.large"
      + kms_key_id                      = (known after apply)
      + monitoring_interval             = 0
      + monitoring_role_arn             = (known after apply)
      + performance_insights_enabled    = false
      + performance_insights_kms_key_id = (known after apply)
      + port                            = (known after apply)
      + preferred_backup_window         = (known after apply)
      + preferred_maintenance_window    = (known after apply)
      + promotion_tier                  = 0
      + publicly_accessible             = false
      + storage_encrypted               = (known after apply)
      + tags                            = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
      + writer                          = (known after apply)
    }

  # module.rds_cluster.aws_rds_cluster_parameter_group.default[0] will be created
  + resource "aws_rds_cluster_parameter_group" "default" {
      + arn         = (known after apply)
      + description = "DB cluster parameter group"
      + family      = "aurora-postgresql10"
      + id          = (known after apply)
      + name        = "iac-dev-rds"
      + name_prefix = (known after apply)
      + tags        = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
    }

  # module.rds_cluster.aws_security_group.default[0] will be created
  + resource "aws_security_group" "default" {
      + arn                    = (known after apply)
      + description            = "Allow inbound traffic from Security Groups and CIDRs"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 3306
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 3306
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 3306
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 3306
            },
        ]
      + name                   = "iac-dev-rds"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name"      = "iac-dev-rds"
          + "Namespace" = "iac"
          + "Stage"     = "dev"
        }
      + vpc_id                 = (known after apply)
    }

  # module.subnets.data.aws_vpc.default will be read during apply
  # (config refers to values not yet known)
 <= data "aws_vpc" "default"  {
      + arn                     = (known after apply)
      + cidr_block              = (known after apply)
      + cidr_block_associations = (known after apply)
      + default                 = (known after apply)
      + dhcp_options_id         = (known after apply)
      + enable_dns_hostnames    = (known after apply)
      + enable_dns_support      = (known after apply)
      + id                      = (known after apply)
      + instance_tenancy        = (known after apply)
      + ipv6_association_id     = (known after apply)
      + ipv6_cidr_block         = (known after apply)
      + main_route_table_id     = (known after apply)
      + owner_id                = (known after apply)
      + state                   = (known after apply)
      + tags                    = (known after apply)
    }

  # module.subnets.aws_eip.default[0] will be created
  + resource "aws_eip" "default" {
      + allocation_id     = (known after apply)
      + association_id    = (known after apply)
      + domain            = (known after apply)
      + id                = (known after apply)
      + instance          = (known after apply)
      + network_interface = (known after apply)
      + private_dns       = (known after apply)
      + private_ip        = (known after apply)
      + public_dns        = (known after apply)
      + public_ip         = (known after apply)
      + public_ipv4_pool  = (known after apply)
      + tags              = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2a"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc               = true
    }

  # module.subnets.aws_eip.default[1] will be created
  + resource "aws_eip" "default" {
      + allocation_id     = (known after apply)
      + association_id    = (known after apply)
      + domain            = (known after apply)
      + id                = (known after apply)
      + instance          = (known after apply)
      + network_interface = (known after apply)
      + private_dns       = (known after apply)
      + private_ip        = (known after apply)
      + public_dns        = (known after apply)
      + public_ip         = (known after apply)
      + public_ipv4_pool  = (known after apply)
      + tags              = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2b"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc               = true
    }

  # module.subnets.aws_eip.default[2] will be created
  + resource "aws_eip" "default" {
      + allocation_id     = (known after apply)
      + association_id    = (known after apply)
      + domain            = (known after apply)
      + id                = (known after apply)
      + instance          = (known after apply)
      + network_interface = (known after apply)
      + private_dns       = (known after apply)
      + private_ip        = (known after apply)
      + public_dns        = (known after apply)
      + public_ip         = (known after apply)
      + public_ipv4_pool  = (known after apply)
      + tags              = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2c"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc               = true
    }

  # module.subnets.aws_nat_gateway.default[0] will be created
  + resource "aws_nat_gateway" "default" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Attributes" = "nat"
          + "Name"       = "iac-dev-ecp-nat-us-west-2a"
          + "Namespace"  = "iac"
          + "Stage"      = "dev"
        }
    }

  # module.subnets.aws_nat_gateway.default[1] will be created
  + resource "aws_nat_gateway" "default" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Attributes" = "nat"
          + "Name"       = "iac-dev-ecp-nat-us-west-2b"
          + "Namespace"  = "iac"
          + "Stage"      = "dev"
        }
    }

  # module.subnets.aws_nat_gateway.default[2] will be created
  + resource "aws_nat_gateway" "default" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Attributes" = "nat"
          + "Name"       = "iac-dev-ecp-nat-us-west-2c"
          + "Namespace"  = "iac"
          + "Stage"      = "dev"
        }
    }

  # module.subnets.aws_network_acl.private[0] will be created
  + resource "aws_network_acl" "private" {
      + egress     = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + id         = (known after apply)
      + ingress    = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + owner_id   = (known after apply)
      + subnet_ids = (known after apply)
      + tags       = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-subnet"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id     = (known after apply)
    }

  # module.subnets.aws_network_acl.public[0] will be created
  + resource "aws_network_acl" "public" {
      + egress     = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + id         = (known after apply)
      + ingress    = [
          + {
              + action          = "allow"
              + cidr_block      = "0.0.0.0/0"
              + from_port       = 0
              + icmp_code       = null
              + icmp_type       = null
              + ipv6_cidr_block = ""
              + protocol        = "-1"
              + rule_no         = 100
              + to_port         = 0
            },
        ]
      + owner_id   = (known after apply)
      + subnet_ids = (known after apply)
      + tags       = {
          + "Attributes"          = "public"
          + "Name"                = "iac-dev-subnet"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "public"
        }
      + vpc_id     = (known after apply)
    }

  # module.subnets.aws_route.default[0] will be created
  + resource "aws_route" "default" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)
    }

  # module.subnets.aws_route.default[1] will be created
  + resource "aws_route" "default" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)
    }

  # module.subnets.aws_route.default[2] will be created
  + resource "aws_route" "default" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)
    }

  # module.subnets.aws_route.public[0] will be created
  + resource "aws_route" "public" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)
    }

  # module.subnets.aws_route_table.private[0] will be created
  + resource "aws_route_table" "private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2a"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id           = (known after apply)
    }

  # module.subnets.aws_route_table.private[1] will be created
  + resource "aws_route_table" "private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2b"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id           = (known after apply)
    }

  # module.subnets.aws_route_table.private[2] will be created
  + resource "aws_route_table" "private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2c"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id           = (known after apply)
    }

  # module.subnets.aws_route_table.public[0] will be created
  + resource "aws_route_table" "public" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Attributes"          = "public"
          + "Name"                = "iac-dev-subnet"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "public"
        }
      + vpc_id           = (known after apply)
    }

  # module.subnets.aws_route_table_association.private[0] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_route_table_association.private[1] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_route_table_association.private[2] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_route_table_association.public[0] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_route_table_association.public[1] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_route_table_association.public[2] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.subnets.aws_subnet.private[0] will be created
  + resource "aws_subnet" "private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2a"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id                          = (known after apply)
    }

  # module.subnets.aws_subnet.private[1] will be created
  + resource "aws_subnet" "private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.32.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2b"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id                          = (known after apply)
    }

  # module.subnets.aws_subnet.private[2] will be created
  + resource "aws_subnet" "private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2c"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.64.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "private"
          + "Name"                = "iac-dev-ecp-private-us-west-2c"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "private"
        }
      + vpc_id                          = (known after apply)
    }

  # module.subnets.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.128.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "public"
          + "Name"                = "iac-dev-ecp-public-us-west-2a"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "public"
        }
      + vpc_id                          = (known after apply)
    }

  # module.subnets.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.160.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "public"
          + "Name"                = "iac-dev-ecp-public-us-west-2b"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "public"
        }
      + vpc_id                          = (known after apply)
    }

  # module.subnets.aws_subnet.public[2] will be created
  + resource "aws_subnet" "public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "us-west-2c"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.192.0/19"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Attributes"          = "public"
          + "Name"                = "iac-dev-ecp-public-us-west-2c"
          + "Namespace"           = "iac"
          + "Stage"               = "dev"
          + "cpco.io/subnet/type" = "public"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_default_security_group.default will be created
  + resource "aws_default_security_group" "default" {
      + arn                    = (known after apply)
      + description            = (known after apply)
      + egress                 = []
      + id                     = (known after apply)
      + ingress                = []
      + name                   = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "Default Security Group"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_internet_gateway.default will be created
  + resource "aws_internet_gateway" "default" {
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name"      = "iac-dev-vpc"
          + "Namespace" = "iac"
          + "Owner"     = "Terraform"
          + "Stage"     = "dev"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_vpc.default will be created
  + resource "aws_vpc" "default" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = true
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = false
      + enable_classiclink_dns_support   = false
      + enable_dns_hostnames             = true
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name"      = "iac-dev-vpc"
          + "Namespace" = "iac"
          + "Owner"     = "Terraform"
          + "Stage"     = "dev"
        }
    }

Plan: 60 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: ./plan/iac-cluster.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "./plan/iac-cluster.plan"
```



If everything looks good, from `terraform plan` then apply real changes using `terraform apply`

### Apply terraform (Create Cluster)

```shell
$ terraform apply "./plan/iac-cluster.plan"
```

```yaml

module.aws_key_pair.tls_private_key.default[0]: Creating...
module.vpc.aws_vpc.default: Creating...
module.rds_cluster.aws_db_parameter_group.default[0]: Creating...
module.subnets.aws_eip.default[0]: Creating...
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Creating...
module.subnets.aws_eip.default[1]: Creating...
module.subnets.aws_eip.default[2]: Creating...
module.aws_key_pair.tls_private_key.default[0]: Creation complete after 1s [id=f3b00895dccd7bcb2da1136e224f31df34ab23ea]
module.aws_key_pair.aws_key_pair.generated[0]: Creating...
module.aws_key_pair.local_file.public_key_openssh[0]: Creating...
module.aws_key_pair.local_file.private_key_pem[0]: Creating...
module.aws_key_pair.local_file.private_key_pem[0]: Creation complete after 0s [id=544c52711d8f8531767cb1725a3aed05a5971895]
module.aws_key_pair.local_file.public_key_openssh[0]: Creation complete after 0s [id=6b0c1f7ca8b3a6f630d1d5668089a743dbec6baa]
module.aws_key_pair.null_resource.chmod[0]: Creating...
module.aws_key_pair.null_resource.chmod[0]: Provisioning with 'local-exec'...
module.aws_key_pair.null_resource.chmod[0] (local-exec): Executing: ["/bin/sh" "-c" "chmod 600 ./secrets/iac-dev-jeffrymilan"]
module.aws_key_pair.null_resource.chmod[0]: Creation complete after 0s [id=3085550157498708206]
module.aws_key_pair.aws_key_pair.generated[0]: Creation complete after 1s [id=iac-dev-jeffrymilan]
module.rds_cluster.aws_db_parameter_group.default[0]: Creation complete after 2s [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Creation complete after 2s [id=iac-dev-rds]
module.subnets.aws_eip.default[1]: Creation complete after 6s [id=eipalloc-03e6311d27c5b4dae]
module.subnets.aws_eip.default[0]: Creation complete after 6s [id=eipalloc-067f0b7de2f879541]
module.subnets.aws_eip.default[2]: Creation complete after 6s [id=eipalloc-06f2200121b103a02]
module.vpc.aws_vpc.default: Still creating... [10s elapsed]
module.vpc.aws_vpc.default: Still creating... [20s elapsed]
module.vpc.aws_vpc.default: Creation complete after 24s [id=vpc-0c6f75b8f8c13b0eb]
module.subnets.data.aws_vpc.default: Refreshing state...
module.vpc.aws_internet_gateway.default: Creating...
module.vpc.aws_default_security_group.default: Creating...
aws_security_group.iac-dev-rds-sg: Creating...
aws_security_group.iac-dev-ec2-sg: Creating...
module.subnets.aws_route_table.public[0]: Creating...
module.subnets.aws_route_table.private[0]: Creating...
module.subnets.aws_subnet.private[1]: Creating...
module.subnets.aws_subnet.private[0]: Creating...
module.subnets.aws_subnet.public[0]: Creating...
module.subnets.aws_subnet.public[1]: Creating...
module.vpc.aws_internet_gateway.default: Creation complete after 2s [id=igw-0c20e97746b2a2a38]
module.subnets.aws_subnet.public[2]: Creating...
aws_security_group.iac-dev-rds-sg: Creation complete after 8s [id=sg-0ff0d95cfba912a9e]
module.subnets.aws_route_table.private[2]: Creating...
module.vpc.aws_default_security_group.default: Creation complete after 8s [id=sg-019f87e6c9e9a80d3]
module.subnets.aws_route_table.private[1]: Creating...
aws_security_group.iac-dev-ec2-sg: Creation complete after 8s [id=sg-05364938edbe679bd]
module.subnets.aws_subnet.private[2]: Creating...
module.subnets.aws_route_table.public[0]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[0]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[0]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[1]: Still creating... [10s elapsed]
module.subnets.aws_subnet.public[1]: Still creating... [10s elapsed]
module.subnets.aws_subnet.public[0]: Still creating... [10s elapsed]
module.subnets.aws_subnet.public[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[1]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[0]: Creation complete after 16s [id=rtb-0851888dfceaf31a3]
aws_security_group_rule.rds_egress[0]: Creating...
module.subnets.aws_route_table.public[0]: Creation complete after 16s [id=rtb-0eaa1ac7f98415dcf]
aws_security_group_rule.rds_ingress[0]: Creating...
module.subnets.aws_subnet.private[0]: Creation complete after 17s [id=subnet-002fba6327d1e8821]
aws_security_group_rule.rds_ingress_dynamic[0]: Creating...
module.subnets.aws_subnet.public[0]: Creation complete after 17s [id=subnet-03deee7ea2ff44cfd]
aws_security_group_rule.rds_ingress[1]: Creating...
module.subnets.aws_subnet.private[1]: Creation complete after 17s [id=subnet-0524d9e94e3425908]
aws_security_group_rule.ingress[1]: Creating...
module.subnets.aws_subnet.public[1]: Creation complete after 17s [id=subnet-09c5835db8671bea2]
aws_security_group_rule.ingress[0]: Creating...
module.subnets.aws_subnet.public[2]: Still creating... [20s elapsed]
module.subnets.aws_route_table.private[1]: Creation complete after 16s [id=rtb-0155cade9eae25508]
module.subnets.aws_subnet.private[2]: Creation complete after 16s [id=subnet-0a22ce8ac1f8b676c]
module.subnets.aws_subnet.public[2]: Creation complete after 22s [id=subnet-03476f668d19d9826]
aws_security_group_rule.egress[0]: Creating...
aws_security_group_rule.ingress[3]: Creating...
aws_security_group_rule.ingress[2]: Creating...
module.subnets.aws_route_table.private[2]: Still creating... [20s elapsed]
aws_security_group_rule.rds_egress[0]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress[0]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress_dynamic[0]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress[1]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[1]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[0]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[2]: Creation complete after 21s [id=rtb-09d0eec274af9083e]
aws_security_group_rule.rds_egress[0]: Creation complete after 11s [id=sgrule-3947895574]
module.rds_cluster.aws_security_group.default[0]: Creating...
module.subnets.aws_network_acl.private[0]: Creating...
aws_security_group_rule.ingress[1]: Creation complete after 10s [id=sgrule-1897119104]
module.subnets.aws_nat_gateway.default[2]: Creating...
aws_security_group_rule.ingress[3]: Still creating... [10s elapsed]
aws_security_group_rule.egress[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[2]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress[0]: Creation complete after 17s [id=sgrule-548998108]
module.subnets.aws_network_acl.public[0]: Creating...
aws_security_group_rule.rds_ingress_dynamic[0]: Still creating... [20s elapsed]
aws_security_group_rule.rds_ingress[1]: Still creating... [20s elapsed]
aws_security_group_rule.ingress[0]: Still creating... [20s elapsed]
module.rds_cluster.aws_security_group.default[0]: Still creating... [10s elapsed]
module.subnets.aws_network_acl.private[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[0]: Creation complete after 21s [id=sgrule-3348750389]
module.subnets.aws_nat_gateway.default[1]: Creating...
aws_security_group_rule.rds_ingress_dynamic[0]: Creation complete after 22s [id=sgrule-2116318304]
module.subnets.aws_nat_gateway.default[0]: Creating...
aws_security_group_rule.ingress[2]: Still creating... [20s elapsed]
aws_security_group_rule.egress[0]: Still creating... [20s elapsed]
aws_security_group_rule.ingress[3]: Still creating... [20s elapsed]
module.subnets.aws_network_acl.public[0]: Still creating... [10s elapsed]
aws_security_group_rule.egress[0]: Creation complete after 22s [id=sgrule-2886035955]
module.subnets.aws_route_table_association.public[1]: Creating...
module.subnets.aws_route_table_association.public[1]: Creation complete after 0s [id=rtbassoc-05b85f1003d49d3d6]
module.subnets.aws_route_table_association.public[2]: Creating...
aws_security_group_rule.rds_ingress[1]: Creation complete after 28s [id=sgrule-3854357414]
module.subnets.aws_route_table_association.public[0]: Creating...
module.rds_cluster.aws_security_group.default[0]: Creation complete after 18s [id=sg-000a5c6f5374cdd58]
module.subnets.aws_route_table_association.private[1]: Creating...
module.subnets.aws_route_table_association.public[0]: Creation complete after 0s [id=rtbassoc-0529e096ca1be10b7]
module.subnets.aws_route_table_association.private[0]: Creating...
module.subnets.aws_route_table_association.public[2]: Creation complete after 1s [id=rtbassoc-02fbf7cdef6bf06e0]
module.subnets.aws_route_table_association.private[2]: Creating...
module.subnets.aws_route_table_association.private[1]: Creation complete after 0s [id=rtbassoc-06a3765e7ae063f7d]
module.subnets.aws_route.public[0]: Creating...
module.subnets.aws_route_table_association.private[0]: Creation complete after 0s [id=rtbassoc-073833bca32caff70]
aws_elb.iac-dev-asg-elb: Creating...
module.subnets.aws_route_table_association.private[2]: Creation complete after 0s [id=rtbassoc-0a6e6ef8cd1fdb5d7]
module.rds_cluster.aws_db_subnet_group.default[0]: Creating...
module.rds_cluster.aws_db_subnet_group.default[0]: Creation complete after 2s [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster.default[0]: Creating...
module.subnets.aws_network_acl.private[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[3]: Creation complete after 29s [id=sgrule-678446235]
module.subnets.aws_route.public[0]: Creation complete after 6s [id=r-rtb-0eaa1ac7f98415dcf1080289494]
module.subnets.aws_network_acl.private[0]: Creation complete after 24s [id=acl-05a86dc3d01942cf3]
module.subnets.aws_network_acl.public[0]: Creation complete after 18s [id=acl-09a01f4830a601545]
aws_security_group_rule.ingress[2]: Still creating... [30s elapsed]
aws_elb.iac-dev-asg-elb: Still creating... [10s elapsed]
aws_security_group_rule.ingress[2]: Creation complete after 35s [id=sgrule-3004151764]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [20s elapsed]
aws_elb.iac-dev-asg-elb: Creation complete after 15s [id=iac-dev-asg-elb]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [30s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [40s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m0s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [50s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Creation complete after 42s [id=iac-dev-rds]
data.template_file.user_data: Refreshing state...
data.template_file.rds: Refreshing state...
module.rds_cluster.aws_rds_cluster_instance.default[0]: Creating...
module.iac-dev-ecp.aws_launch_template.default[0]: Creating...
module.iac-dev-ecp.aws_launch_template.default[0]: Creation complete after 0s [id=lt-072bcbab9328c99b0]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Creating...
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m0s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [10s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m10s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [20s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m30s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m20s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [30s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m40s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m30s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [40s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [40s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Creation complete after 43s [id=iac-dev-ec2-asg-20200210205918307100000003]
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Creating...
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Creating...
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m50s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m40s elapsed]
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Creation complete after 6s [id=iac-dev-ec2-asg-scale-up]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Creating...
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Creation complete after 6s [id=iac-dev-ec2-asg-scale-down]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Creating...
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m40s elapsed]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Creation complete after 0s [id=iac-dev-ec2-asg-cpu-utilization-high]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [50s elapsed]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Creation complete after 6s [id=iac-dev-ec2-asg-cpu-utilization-low]
module.subnets.aws_nat_gateway.default[2]: Still creating... [2m0s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m50s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m0s elapsed]
module.subnets.aws_nat_gateway.default[2]: Creation complete after 2m5s [id=nat-0851123fd501220f6]
module.subnets.aws_nat_gateway.default[1]: Creation complete after 2m0s [id=nat-03b4c0955b5ccefe2]
module.subnets.aws_nat_gateway.default[0]: Creation complete after 1m59s [id=nat-01681f52b1190f8c8]
module.subnets.aws_route.default[0]: Creating...
module.subnets.aws_route.default[1]: Creating...
module.subnets.aws_route.default[2]: Creating...
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m10s elapsed]
module.subnets.aws_route.default[2]: Creation complete after 6s [id=r-rtb-09d0eec274af9083e1080289494]
module.subnets.aws_route.default[1]: Creation complete after 6s [id=r-rtb-0155cade9eae255081080289494]
module.subnets.aws_route.default[0]: Creation complete after 6s [id=r-rtb-0851888dfceaf31a31080289494]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [2m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [3m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [4m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [5m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [6m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [6m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Creation complete after 6m13s [id=iac-dev-rds-1]

Apply complete! Resources: 60 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

```

### Results: 
```yaml

Outputs:
alb_dns_name = iac-dev-asg-elb-1600553309.us-west-2.elb.amazonaws.com
arn = arn:aws:rds:us-west-2:662028814455:cluster:iac-dev-rds
autoscaling_group_arn = arn:aws:autoscaling:us-west-2:662028814455:autoScalingGroup:b201063c-014c-4874-a5af-8eebaf75868f:autoScalingGroupName/iac-dev-ec2-asg-20200210205918307100000003
autoscaling_group_default_cooldown = 300
autoscaling_group_desired_capacity = 1
autoscaling_group_health_check_grace_period = 300
autoscaling_group_health_check_type = EC2
autoscaling_group_id = iac-dev-ec2-asg-20200210205918307100000003
autoscaling_group_max_size = 2
autoscaling_group_min_size = 1
autoscaling_group_name = iac-dev-ec2-asg-20200210205918307100000003
cluster_identifier = iac-dev-rds
cluster_resource_id = cluster-NC4ANVLTJEU4KAZXSOWXOJAFSE
database_name = iac_db
dbi_resource_ids = [
  "db-XJBERRRZWHPI3ESAC7XG76BQUE",
]
endpoint = iac-dev-rds.cluster-ceiofvzcgozo.us-west-2.rds.amazonaws.com
launch_template_arn = arn:aws:ec2:us-west-2::launch-template/lt-072bcbab9328c99b0
launch_template_id = lt-072bcbab9328c99b0
master_host = 
master_username = adminrds
private_subnet_cidrs = [
  "10.0.0.0/19",
  "10.0.32.0/19",
  "10.0.64.0/19",
]
public_subnet_cidrs = [
  "10.0.128.0/19",
  "10.0.160.0/19",
  "10.0.192.0/19",
]
reader_endpoint = iac-dev-rds.cluster-ro-ceiofvzcgozo.us-west-2.rds.amazonaws.com
replicas_host = 
vpc_cidr = 10.0.0.0/16
```

### Check Endpoint: 
Once `terraform apply` is `successful`, you will see the `elb_dns_name` configured as a part of output. you can hit `elb_dns_name` in your browser and should see the sample response from nginx container deployed or you can access `elb_dns_name` from CLI as well as given below.

```bash
while true; do curl -s -o /dev/null -w "%{http_code} => OK\n" iac-dev-asg-elb-1600553309.us-west-2.elb.amazonaws.com; done

200 => OK
200 => OK
200 => OK
200 => OK
200 => OK
200 => OK
200 => OK
200 => OK
200 => OK
```

### Web App - powered by: Docker with Nginx: 

> http://iac-dev-asg-elb-1600553309.us-west-2.elb.amazonaws.com

![WebApp](https://imgur.com/ZrwaHzO.png)


### Terraform State File ( Private API) - (this is for storing state file in S3) - Do not execute (Access Denied)

The state file format is a private API that changes with every release and is meant only for internal use within Terraform. You should never edit the Terraform state files by hand or write code that reads them directly.

```yaml
Initializing modules...

Initializing the backend...

Error: Error loading state:
    AccessDenied: Access Denied
        status code: 403, request id: AADE8093192B55BC, host id: 30Sn4g1ljvBiN50bVI5HKaEXkZO+FqE8SZ+YiINTiPXpPqcS1DuWF/ZvLrML4iZ7t7wvGhNmOjA=

Terraform failed to load the default state from the "s3" backend.
State migration cannot occur unless the state can be loaded. Backend
modification and state migration has been aborted. The state in both the
source and the destination remain unmodified. Please resolve the
above error and try again.
```


### Destroy Infrastructure(clean-up)

```
$ terraform plan -destroy -var-file=iac-cluster.tfvars -out=./destroy/iac-cluster.destroy
```

```yaml
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.aws_key_pair.tls_private_key.default[0]: Refreshing state... [id=1af8cdb01a0d33950630bf133e6aff7628283d38]
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.aws_key_pair.local_file.public_key_openssh[0]: Refreshing state... [id=76b45103a42dfd5ea48cf78e43c571ba3835662d]
module.aws_key_pair.local_file.private_key_pem[0]: Refreshing state... [id=3aafbae020fc12f3acbdfce253f61a716013ed4c]
module.aws_key_pair.null_resource.chmod[0]: Refreshing state... [id=9145674845761086373]
module.subnets.aws_eip.default[1]: Refreshing state... [id=eipalloc-0ea37feffa5670376]
module.subnets.aws_eip.default[0]: Refreshing state... [id=eipalloc-0ee98473a1c471528]
module.subnets.aws_eip.default[2]: Refreshing state... [id=eipalloc-0c9ebae8a02b3add0]
module.vpc.aws_vpc.default: Refreshing state... [id=vpc-06930f221f81bb801]
module.aws_key_pair.aws_key_pair.generated[0]: Refreshing state... [id=iac-dev-jeffrymilan]
module.subnets.data.aws_availability_zones.available: Refreshing state...
module.rds_cluster.aws_db_parameter_group.default[0]: Refreshing state... [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Refreshing state... [id=iac-dev-rds]
module.vpc.aws_default_security_group.default: Refreshing state... [id=sg-031783e2203d3d78f]
module.vpc.aws_internet_gateway.default: Refreshing state... [id=igw-055161e27697962d5]
module.subnets.data.aws_vpc.default: Refreshing state...
aws_security_group.iac-dev-rds-sg: Refreshing state... [id=sg-091cd0f41fce76446]
aws_security_group.iac-dev-ec2-sg: Refreshing state... [id=sg-0f202a554030214fb]
aws_security_group_rule.egress[0]: Refreshing state... [id=sgrule-1417906670]
aws_security_group_rule.ingress[1]: Refreshing state... [id=sgrule-631296820]
aws_security_group_rule.ingress[2]: Refreshing state... [id=sgrule-3233341605]
aws_security_group_rule.ingress[0]: Refreshing state... [id=sgrule-2469039745]
aws_security_group_rule.ingress[3]: Refreshing state... [id=sgrule-47396811]
aws_security_group_rule.rds_ingress_dynamic[0]: Refreshing state... [id=sgrule-214679645]
aws_security_group_rule.rds_egress[0]: Refreshing state... [id=sgrule-3431259760]
aws_security_group_rule.rds_ingress[1]: Refreshing state... [id=sgrule-1111972389]
aws_security_group_rule.rds_ingress[0]: Refreshing state... [id=sgrule-2269282911]
module.rds_cluster.aws_security_group.default[0]: Refreshing state... [id=sg-0a5f58ec1536230f7]
module.subnets.aws_subnet.private[0]: Refreshing state... [id=subnet-06460b59759808ae6]
module.subnets.aws_subnet.private[1]: Refreshing state... [id=subnet-01f68a89a048e7ca7]
module.subnets.aws_subnet.private[2]: Refreshing state... [id=subnet-091cb53cde2f5a18b]
module.subnets.aws_route_table.private[0]: Refreshing state... [id=rtb-0412971a9a2b0af17]
module.subnets.aws_route_table.private[1]: Refreshing state... [id=rtb-0514727ce29bf5a41]
module.subnets.aws_subnet.public[1]: Refreshing state... [id=subnet-023871b75b6bbbb8d]
module.subnets.aws_subnet.public[0]: Refreshing state... [id=subnet-09e4e142936b2d83a]
module.subnets.aws_route_table.private[2]: Refreshing state... [id=rtb-0626bed0831231706]
module.subnets.aws_subnet.public[2]: Refreshing state... [id=subnet-01ba667d8ecf13479]
module.subnets.aws_route_table.public[0]: Refreshing state... [id=rtb-025bbe4df51dea065]
module.subnets.aws_route.public[0]: Refreshing state... [id=r-rtb-025bbe4df51dea0651080289494]
module.subnets.aws_nat_gateway.default[2]: Refreshing state... [id=nat-06ba0fed9a127dbc1]
module.subnets.aws_network_acl.public[0]: Refreshing state... [id=acl-098887751d5dd5b90]
module.subnets.aws_nat_gateway.default[1]: Refreshing state... [id=nat-0622789960bb7daa0]
module.subnets.aws_nat_gateway.default[0]: Refreshing state... [id=nat-0893089d49c77ee11]
module.subnets.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-0b9bc963f27a64293]
module.subnets.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-0dca805f0d16a0148]
module.subnets.aws_route_table_association.public[2]: Refreshing state... [id=rtbassoc-0a6dfb6e2a6e399ec]
aws_elb.iac-dev-asg-elb: Refreshing state... [id=iac-dev-asg-elb]
module.subnets.aws_network_acl.private[0]: Refreshing state... [id=acl-0037a6c512b9ea029]
module.subnets.aws_route_table_association.private[2]: Refreshing state... [id=rtbassoc-0bd3af89d44c3ab6e]
module.subnets.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-0b2140ea42b1b8b3c]
module.subnets.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-09b1c565668e1380e]
module.rds_cluster.aws_db_subnet_group.default[0]: Refreshing state... [id=iac-dev-rds]
module.subnets.aws_route.default[0]: Refreshing state... [id=r-rtb-0412971a9a2b0af171080289494]
module.subnets.aws_route.default[1]: Refreshing state... [id=r-rtb-0514727ce29bf5a411080289494]
module.subnets.aws_route.default[2]: Refreshing state... [id=r-rtb-0626bed08312317061080289494]
module.rds_cluster.aws_rds_cluster.default[0]: Refreshing state... [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Refreshing state... [id=iac-dev-rds-1]
data.template_file.rds: Refreshing state...
data.template_file.user_data: Refreshing state...
module.iac-dev-ecp.aws_launch_template.default[0]: Refreshing state... [id=lt-0a2928df81bb94676]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Refreshing state... [id=iac-dev-ec2-asg-20200210203901665700000003]
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Refreshing state... [id=iac-dev-ec2-asg-scale-down]
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Refreshing state... [id=iac-dev-ec2-asg-scale-up]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Refreshing state... [id=iac-dev-ec2-asg-cpu-utilization-high]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Refreshing state... [id=iac-dev-ec2-asg-cpu-utilization-low]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_elb.iac-dev-asg-elb will be destroyed
  - resource "aws_elb" "iac-dev-asg-elb" {
      - arn                         = "arn:aws:elasticloadbalancing:us-west-2::loadbalancer/iac-dev-asg-elb" -> null
      - availability_zones          = [
          - "us-west-2a",
          - "us-west-2b",
          - "us-west-2c",
        ] -> null
      - connection_draining         = true -> null
      - connection_draining_timeout = 400 -> null
      - cross_zone_load_balancing   = true -> null
      - dns_name                    = "iac-dev-asg-elb-1403180753.us-west-2.elb.amazonaws.com" -> null
      - id                          = "iac-dev-asg-elb" -> null
      - idle_timeout                = 400 -> null
      - instances                   = [
          - "i-0b8f060622d2257e7",
        ] -> null
      - internal                    = false -> null
      - name                        = "iac-dev-asg-elb" -> null
      - security_groups             = [
          - "sg-0f202a554030214fb",
        ] -> null
      - source_security_group       = "662028814455/iac-dev-ec2-sg" -> null
      - source_security_group_id    = "sg-0f202a554030214fb" -> null
      - subnets                     = [
          - "subnet-01ba667d8ecf13479",
          - "subnet-023871b75b6bbbb8d",
          - "subnet-09e4e142936b2d83a",
        ] -> null
      - tags                        = {} -> null
      - zone_id                     = "Z1H1FL5HABSF5" -> null

      - health_check {
          - healthy_threshold   = 10 -> null
          - interval            = 30 -> null
          - target              = "TCP:8080" -> null
          - timeout             = 5 -> null
          - unhealthy_threshold = 2 -> null
        }

      - listener {
          - instance_port     = 8080 -> null
          - instance_protocol = "tcp" -> null
          - lb_port           = 80 -> null
          - lb_protocol       = "tcp" -> null
        }
    }

  # aws_security_group.iac-dev-ec2-sg will be destroyed
  - resource "aws_security_group" "iac-dev-ec2-sg" {
      - arn                    = "arn:aws:ec2:us-west-2:662028814455:security-group/sg-0f202a554030214fb" -> null
      - description            = "security group for ec2 instance" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0f202a554030214fb" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 22
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 443
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 443
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 8080
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 8080
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 80
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 80
            },
        ] -> null
      - name                   = "iac-dev-ec2-sg" -> null
      - owner_id               = "662028814455" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name"  = "iac-dev-ec2-sg"
          - "Owner" = "Terraform"
        } -> null
      - vpc_id                 = "vpc-06930f221f81bb801" -> null
    }

  # aws_security_group.iac-dev-rds-sg will be destroyed
  - resource "aws_security_group" "iac-dev-rds-sg" {
      - arn                    = "arn:aws:ec2:us-west-2:662028814455:security-group/sg-091cd0f41fce76446" -> null
      - description            = "security group for rds instances" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-091cd0f41fce76446" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 65535
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 5432
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 5432
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 8080
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 8080
            },
        ] -> null
      - name                   = "iac-dev-rds-sg" -> null
      - owner_id               = "662028814455" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name"  = "iac-dev-rds-sg"
          - "Owner" = "Terraform"
        } -> null
      - vpc_id                 = "vpc-06930f221f81bb801" -> null
    }

  # aws_security_group_rule.egress[0] will be destroyed
  - resource "aws_security_group_rule" "egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-1417906670" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-0f202a554030214fb" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.ingress[0] will be destroyed
  - resource "aws_security_group_rule" "ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 22 -> null
      - id                = "sgrule-2469039745" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0f202a554030214fb" -> null
      - self              = false -> null
      - to_port           = 22 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.ingress[1] will be destroyed
  - resource "aws_security_group_rule" "ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 80 -> null
      - id                = "sgrule-631296820" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0f202a554030214fb" -> null
      - self              = false -> null
      - to_port           = 80 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.ingress[2] will be destroyed
  - resource "aws_security_group_rule" "ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 8080 -> null
      - id                = "sgrule-3233341605" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0f202a554030214fb" -> null
      - self              = false -> null
      - to_port           = 8080 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.ingress[3] will be destroyed
  - resource "aws_security_group_rule" "ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 443 -> null
      - id                = "sgrule-47396811" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0f202a554030214fb" -> null
      - self              = false -> null
      - to_port           = 443 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.rds_egress[0] will be destroyed
  - resource "aws_security_group_rule" "rds_egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-3431259760" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-091cd0f41fce76446" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.rds_ingress[0] will be destroyed
  - resource "aws_security_group_rule" "rds_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 8080 -> null
      - id                = "sgrule-2269282911" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-091cd0f41fce76446" -> null
      - self              = false -> null
      - to_port           = 8080 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.rds_ingress[1] will be destroyed
  - resource "aws_security_group_rule" "rds_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 5432 -> null
      - id                = "sgrule-1111972389" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-091cd0f41fce76446" -> null
      - self              = false -> null
      - to_port           = 5432 -> null
      - type              = "ingress" -> null
    }

  # aws_security_group_rule.rds_ingress_dynamic[0] will be destroyed
  - resource "aws_security_group_rule" "rds_ingress_dynamic" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-214679645" -> null
      - ipv6_cidr_blocks  = [] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-091cd0f41fce76446" -> null
      - self              = false -> null
      - to_port           = 65535 -> null
      - type              = "ingress" -> null
    }

  # module.aws_key_pair.aws_key_pair.generated[0] will be destroyed
  - resource "aws_key_pair" "generated" {
      - fingerprint = "1e:a8:f3:70:42:ee:60:40:8c:a3:91:b6:d1:aa:a6:cb" -> null
      - id          = "iac-dev-jeffrymilan" -> null
      - key_name    = "iac-dev-jeffrymilan" -> null
      - key_pair_id = "key-05189f29d1719793a" -> null
      - public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq8OEWGWSVmtxC1FMADyHJFf+peYtxH3ZS/AqgOavVIWkV/aO1Y8eiPtY9HRAwZ6yqEg3eVhq7oGgrzBY0eD56bxMjmsy8eK8P4tCHhMR4073/73YFNiTSh/TW/lM1dUdwdxzE3cBpMy3xbhnG4qhjP7j6TmuYkDptd2zX6TydWC7hX3cowPRBGDeLrLmSn5Oukn2im3NtZJIuMIo/F4G+Ef1NmLaGUA4wXHbxiTvhRJOlI+7T8HEeFCIeOEramrN3bmRwojx3LBxQrUsAuh80UpszgduTRrf3x7NOcj/L+dFNiYi7xUEeD3B6dgyONZ1c0+R2LM7hy+7DunoKItbd" -> null
      - tags        = {} -> null
    }

  # module.aws_key_pair.local_file.private_key_pem[0] will be destroyed
  - resource "local_file" "private_key_pem" {
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "./secrets/iac-dev-jeffrymilan" -> null
      - id                   = "3aafbae020fc12f3acbdfce253f61a716013ed4c" -> null
      - sensitive_content    = (sensitive value)
    }

  # module.aws_key_pair.local_file.public_key_openssh[0] will be destroyed
  - resource "local_file" "public_key_openssh" {
      - content              = <<~EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq8OEWGWSVmtxC1FMADyHJFf+peYtxH3ZS/AqgOavVIWkV/aO1Y8eiPtY9HRAwZ6yqEg3eVhq7oGgrzBY0eD56bxMjmsy8eK8P4tCHhMR4073/73YFNiTSh/TW/lM1dUdwdxzE3cBpMy3xbhnG4qhjP7j6TmuYkDptd2zX6TydWC7hX3cowPRBGDeLrLmSn5Oukn2im3NtZJIuMIo/F4G+Ef1NmLaGUA4wXHbxiTvhRJOlI+7T8HEeFCIeOEramrN3bmRwojx3LBxQrUsAuh80UpszgduTRrf3x7NOcj/L+dFNiYi7xUEeD3B6dgyONZ1c0+R2LM7hy+7DunoKItbd
        EOT -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "./secrets/iac-dev-jeffrymilan.pub" -> null
      - id                   = "76b45103a42dfd5ea48cf78e43c571ba3835662d" -> null
    }

  # module.aws_key_pair.null_resource.chmod[0] will be destroyed
  - resource "null_resource" "chmod" {
      - id       = "9145674845761086373" -> null
      - triggers = {
          - "local_file_private_key_pem" = "local_file.private_key_pem"
        } -> null
    }

  # module.aws_key_pair.tls_private_key.default[0] will be destroyed
  - resource "tls_private_key" "default" {
      - algorithm                  = "RSA" -> null
      - ecdsa_curve                = "P224" -> null
      - id                         = "1af8cdb01a0d33950630bf133e6aff7628283d38" -> null
      - private_key_pem            = (sensitive value)
      - public_key_fingerprint_md5 = "96:8e:5d:13:a2:77:29:66:f0:5f:2a:83:06:a5:f0:e6" -> null
      - public_key_openssh         = <<~EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq8OEWGWSVmtxC1FMADyHJFf+peYtxH3ZS/AqgOavVIWkV/aO1Y8eiPtY9HRAwZ6yqEg3eVhq7oGgrzBY0eD56bxMjmsy8eK8P4tCHhMR4073/73YFNiTSh/TW/lM1dUdwdxzE3cBpMy3xbhnG4qhjP7j6TmuYkDptd2zX6TydWC7hX3cowPRBGDeLrLmSn5Oukn2im3NtZJIuMIo/F4G+Ef1NmLaGUA4wXHbxiTvhRJOlI+7T8HEeFCIeOEramrN3bmRwojx3LBxQrUsAuh80UpszgduTRrf3x7NOcj/L+dFNiYi7xUEeD3B6dgyONZ1c0+R2LM7hy+7DunoKItbd
        EOT -> null
      - public_key_pem             = <<~EOT
            -----BEGIN PUBLIC KEY-----
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqvDhFhlklZrcQtRTAA8h
            yRX/qXmLcR92UvwKoDmr1SFpFf2jtWPHoj7WPR0QMGesqhIN3lYau6BoK8wWNHg+
            em8TI5rMvHivD+LQh4TEeNO9/+92BTYk0of01v5TNXVHcHccxN3AaTMt8W4ZxuKo
            Yz+4+k5rmJA6bXds1+k8nVgu4V93KMD0QRg3i6y5kp+TrpJ9optzbWSSLjCKPxeB
            vhH9TZi2hlAOMFx28Yk74USTpSPu0/BxHhQiHjhK2pqzd25kcKI8dywcUK1LALof
            NFKbM4Hbk0a398ezTnI/y/nRTYmIu8VBHg9wenYMjjWdXNPkdizO4cvuw7p6CiLW
            3QIDAQAB
            -----END PUBLIC KEY-----
        EOT -> null
      - rsa_bits                   = 2048 -> null
    }

  # module.iac-dev-ecp.aws_autoscaling_group.default[0] will be destroyed
  - resource "aws_autoscaling_group" "default" {
      - arn                       = "arn:aws:autoscaling:us-west-2:662028814455:autoScalingGroup:e029a98d-1ca4-4ec9-b4e2-ba119b0aedc4:autoScalingGroupName/iac-dev-ec2-asg-20200210203901665700000003" -> null
      - availability_zones        = [
          - "us-west-2a",
          - "us-west-2b",
          - "us-west-2c",
        ] -> null
      - default_cooldown          = 300 -> null
      - desired_capacity          = 1 -> null
      - enabled_metrics           = [
          - "GroupDesiredCapacity",
          - "GroupInServiceInstances",
          - "GroupMaxSize",
          - "GroupMinSize",
          - "GroupPendingInstances",
          - "GroupStandbyInstances",
          - "GroupTerminatingInstances",
          - "GroupTotalInstances",
        ] -> null
      - force_delete              = false -> null
      - health_check_grace_period = 300 -> null
      - health_check_type         = "EC2" -> null
      - id                        = "iac-dev-ec2-asg-20200210203901665700000003" -> null
      - load_balancers            = [
          - "iac-dev-asg-elb",
        ] -> null
      - max_instance_lifetime     = 0 -> null
      - max_size                  = 2 -> null
      - metrics_granularity       = "1Minute" -> null
      - min_elb_capacity          = 0 -> null
      - min_size                  = 1 -> null
      - name                      = "iac-dev-ec2-asg-20200210203901665700000003" -> null
      - name_prefix               = "iac-dev-ec2-asg-" -> null
      - protect_from_scale_in     = false -> null
      - service_linked_role_arn   = "arn:aws:iam::662028814455:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" -> null
      - suspended_processes       = [] -> null
      - tags                      = [
          - {
              - "key"                 = "Name"
              - "propagate_at_launch" = "true"
              - "value"               = "iac-dev-ec2"
            },
          - {
              - "key"                 = "Namespace"
              - "propagate_at_launch" = "true"
              - "value"               = "iac"
            },
          - {
              - "key"                 = "Owner"
              - "propagate_at_launch" = "true"
              - "value"               = "Terraform"
            },
          - {
              - "key"                 = "Stage"
              - "propagate_at_launch" = "true"
              - "value"               = "dev"
            },
          - {
              - "key"                 = "Tier"
              - "propagate_at_launch" = "true"
              - "value"               = "1"
            },
        ] -> null
      - target_group_arns         = [] -> null
      - termination_policies      = [
          - "Default",
        ] -> null
      - vpc_zone_identifier       = [
          - "subnet-01f68a89a048e7ca7",
          - "subnet-06460b59759808ae6",
          - "subnet-091cb53cde2f5a18b",
        ] -> null
      - wait_for_capacity_timeout = "10m" -> null
      - wait_for_elb_capacity     = 0 -> null

      - launch_template {
          - id      = "lt-0a2928df81bb94676" -> null
          - name    = "iac-dev-ec2-asg-20200210203900858100000001" -> null
          - version = "$Latest" -> null
        }
    }

  # module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0] will be destroyed
  - resource "aws_autoscaling_policy" "scale_down" {
      - adjustment_type           = "ChangeInCapacity" -> null
      - arn                       = "arn:aws:autoscaling:us-west-2:662028814455:scalingPolicy:f9da1b42-5b7c-4d19-9792-f9d0f521a578:autoScalingGroupName/iac-dev-ec2-asg-20200210203901665700000003:policyName/iac-dev-ec2-asg-scale-down" -> null
      - autoscaling_group_name    = "iac-dev-ec2-asg-20200210203901665700000003" -> null
      - cooldown                  = 300 -> null
      - estimated_instance_warmup = 0 -> null
      - id                        = "iac-dev-ec2-asg-scale-down" -> null
      - name                      = "iac-dev-ec2-asg-scale-down" -> null
      - policy_type               = "SimpleScaling" -> null
      - scaling_adjustment        = -1 -> null
    }

  # module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0] will be destroyed
  - resource "aws_autoscaling_policy" "scale_up" {
      - adjustment_type           = "ChangeInCapacity" -> null
      - arn                       = "arn:aws:autoscaling:us-west-2:662028814455:scalingPolicy:be05bbcb-5d15-4e89-96dc-a83610b792a6:autoScalingGroupName/iac-dev-ec2-asg-20200210203901665700000003:policyName/iac-dev-ec2-asg-scale-up" -> null
      - autoscaling_group_name    = "iac-dev-ec2-asg-20200210203901665700000003" -> null
      - cooldown                  = 300 -> null
      - estimated_instance_warmup = 0 -> null
      - id                        = "iac-dev-ec2-asg-scale-up" -> null
      - name                      = "iac-dev-ec2-asg-scale-up" -> null
      - policy_type               = "SimpleScaling" -> null
      - scaling_adjustment        = 1 -> null
    }

  # module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0] will be destroyed
  - resource "aws_cloudwatch_metric_alarm" "cpu_high" {
      - actions_enabled           = true -> null
      - alarm_actions             = [
          - "arn:aws:autoscaling:us-west-2:662028814455:scalingPolicy:be05bbcb-5d15-4e89-96dc-a83610b792a6:autoScalingGroupName/iac-dev-ec2-asg-20200210203901665700000003:policyName/iac-dev-ec2-asg-scale-up",
        ] -> null
      - alarm_description         = "Scale up if CPU utilization is above 80 for 300 seconds" -> null
      - alarm_name                = "iac-dev-ec2-asg-cpu-utilization-high" -> null
      - arn                       = "arn:aws:cloudwatch:us-west-2:662028814455:alarm:iac-dev-ec2-asg-cpu-utilization-high" -> null
      - comparison_operator       = "GreaterThanOrEqualToThreshold" -> null
      - datapoints_to_alarm       = 0 -> null
      - dimensions                = {
          - "AutoScalingGroupName" = "iac-dev-ec2-asg-20200210203901665700000003"
        } -> null
      - evaluation_periods        = 2 -> null
      - id                        = "iac-dev-ec2-asg-cpu-utilization-high" -> null
      - insufficient_data_actions = [] -> null
      - metric_name               = "CPUUtilization" -> null
      - namespace                 = "AWS/EC2" -> null
      - ok_actions                = [] -> null
      - period                    = 300 -> null
      - statistic                 = "Average" -> null
      - tags                      = {} -> null
      - threshold                 = 80 -> null
      - treat_missing_data        = "missing" -> null
    }

  # module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0] will be destroyed
  - resource "aws_cloudwatch_metric_alarm" "cpu_low" {
      - actions_enabled           = true -> null
      - alarm_actions             = [
          - "arn:aws:autoscaling:us-west-2:662028814455:scalingPolicy:f9da1b42-5b7c-4d19-9792-f9d0f521a578:autoScalingGroupName/iac-dev-ec2-asg-20200210203901665700000003:policyName/iac-dev-ec2-asg-scale-down",
        ] -> null
      - alarm_description         = "Scale down if the CPU utilization is below 20 for 300 seconds" -> null
      - alarm_name                = "iac-dev-ec2-asg-cpu-utilization-low" -> null
      - arn                       = "arn:aws:cloudwatch:us-west-2:662028814455:alarm:iac-dev-ec2-asg-cpu-utilization-low" -> null
      - comparison_operator       = "LessThanOrEqualToThreshold" -> null
      - datapoints_to_alarm       = 0 -> null
      - dimensions                = {
          - "AutoScalingGroupName" = "iac-dev-ec2-asg-20200210203901665700000003"
        } -> null
      - evaluation_periods        = 2 -> null
      - id                        = "iac-dev-ec2-asg-cpu-utilization-low" -> null
      - insufficient_data_actions = [] -> null
      - metric_name               = "CPUUtilization" -> null
      - namespace                 = "AWS/EC2" -> null
      - ok_actions                = [] -> null
      - period                    = 300 -> null
      - statistic                 = "Average" -> null
      - tags                      = {} -> null
      - threshold                 = 20 -> null
      - treat_missing_data        = "missing" -> null
    }

  # module.iac-dev-ecp.aws_launch_template.default[0] will be destroyed
  - resource "aws_launch_template" "default" {
      - arn                                  = "arn:aws:ec2:us-west-2::launch-template/lt-0a2928df81bb94676" -> null
      - default_version                      = 1 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = "false" -> null
      - id                                   = "lt-0a2928df81bb94676" -> null
      - image_id                             = "ami-0d1cd67c26f5fca19" -> null
      - instance_initiated_shutdown_behavior = "terminate" -> null
      - instance_type                        = "t2.micro" -> null
      - key_name                             = "iac-dev-jeffrymilan" -> null
      - latest_version                       = 1 -> null
      - name                                 = "iac-dev-ec2-asg-20200210203900858100000001" -> null
      - name_prefix                          = "iac-dev-ec2-asg-" -> null
      - security_group_names                 = [] -> null
      - tags                                 = {
          - "Name"      = "iac-dev-ec2"
          - "Namespace" = "iac"
          - "Owner"     = "Terraform"
          - "Stage"     = "dev"
          - "Tier"      = "1"
        } -> null
      - user_data                            = "IyEvdXNyL2Jpbi9lbnYgYmFzaAoKaWYgWyAiJCguIC9ldGMvb3MtcmVsZWFzZTsgZWNobyAkTkFNRSkiID0gIlVidW50dSIgXTsgdGhlbgogIGFwdC1nZXQgdXBkYXRlCiAgYXB0LWdldCAteSBpbnN0YWxsIGZpZ2xldAogIFNTSF9VU0VSPXVidW50dQplbHNlCiAgeXVtIGluc3RhbGwgZXBlbC1yZWxlYXNlIC15CiAgeXVtIGluc3RhbGwgZmlnbGV0IC15CiAgU1NIX1VTRVI9ZWMyLXVzZXIKZmkKIyBHZW5lcmF0ZSBzeXN0ZW0gYmFubmVyCmZpZ2xldCAiV2VsY29tZSB0byBDb250cm9sIFNlcnZlciIgPiAvZXRjL21vdGQKCgojIwojIyBTZXR1cCBTU0ggQ29uZmlnCiMjCmNhdCA8PCJfX0VPRl9fIiA+IC9ob21lL1NTSF9VU0VSLy5zc2gvY29uZmlnCkhvc3QgKgogICAgU3RyaWN0SG9zdEtleUNoZWNraW5nIG5vCl9fRU9GX18KY2htb2QgNjAwIC9ob21lLyRTU0hfVVNFUi8uc3NoL2NvbmZpZwpjaG93biAkU1NIX1VTRVI6JFNTSF9VU0VSIC9ob21lL1NTSF9VU0VSLy5zc2gvY29uZmlnCgojIwojIyBTZXR1cCBIVE1MCiMjCnN1ZG8gbWtkaXIgLXAgL29wdC9pYWMKc3VkbyBjaG93biAtUiBhZG1pbi5hZG1pbiAvb3B0L2lhYwpjYXQgPDwiX19FT0ZfXyIgPiAvb3B0L2lhYy9pbmRleC5odG1sCjxoMT5EYXRhYmFzZSBJbmZvOiA8L2gxPgo8cD48c3Ryb25nPlBvc3RncmVTUUwgRW5kb2ludDo8L3N0cm9uZz4gaWFjLWRldi1yZHMuY2x1c3Rlci1jZWlvZnZ6Y2dvem8udXMtd2VzdC0yLnJkcy5hbWF6b25hd3MuY29tPC9wPgo8cD48c3Ryb25nPlBvc3RncmVTUUwgSW5zdGFuY2U6PC9zdHJvbmc+IGlhY19kYjwvcD4KCjxmb290ZXI+CiAgPHA+PHN0cm9uZz5Qb3N0ZWQgYnk6PC9zdHJvbmc+IEplZmZyeSBNaWxhbjwvcD4KICA8cD48c3Ryb25nPkNvbnRhY3QgaW5mb3JtYXRpb246PC9zdHJvbmc+IDxhIGhyZWY9Im1haWx0bzpqZWZmcnkubWlsYW5AZ21haWwuY29tIj5qdG1pbGFuQGdtYWlsLmNvbTwvYT4uPC9wPgo8L2Zvb3Rlcj4KPHA+PHN0cm9uZz5Ob3RlOjwvc3Ryb25nPiBUaGUgZW52aXJvbm1lbnQgc3BlY2lmaWVkIGlzIGEgbmFpdmUgcmVwcmVzZW50YXRpb24gb2YgYSB3ZWIgYXBwbGljYXRpb24gd2l0aCBhIGRhdGFiYXNlIGJhY2tlbmQuPC9wPgpfX0VPRl9fCgojIS9iaW4vYmFzaAphcHQtZ2V0IHVwZGF0ZQphcHQgLXkgaW5zdGFsbCBuZ2lueAphcHQgLXkgaW5zdGFsbCBkb2NrZXIuaW8KdWZ3IGFsbG93ICdOZ2lueCBIVFRQJwpzeXN0ZW1jdGwgc3RhcnQgZG9ja2VyCnN5c3RlbWN0bCBlbmFibGUgZG9ja2VyCmRvY2tlciBydW4gLS1uYW1lIGlhYy1uZ2lueCAtLXJlc3RhcnQ9dW5sZXNzLXN0b3BwZWQgLXYgL29wdC9pYWM6L3Vzci9zaGFyZS9uZ2lueC9odG1sOnJvIC1kIC1wIDgwODA6ODAgbmdpbngKCg==" -> null
      - vpc_security_group_ids               = [] -> null

      - monitoring {
          - enabled = true -> null
        }

      - network_interfaces {
          - associate_public_ip_address = "true" -> null
          - delete_on_termination       = true -> null
          - description                 = "iac-dev-ec2-asg" -> null
          - device_index                = 0 -> null
          - ipv4_address_count          = 0 -> null
          - ipv4_addresses              = [] -> null
          - ipv6_address_count          = 0 -> null
          - ipv6_addresses              = [] -> null
          - security_groups             = [
              - "sg-0f202a554030214fb",
            ] -> null
        }

      - tag_specifications {
          - resource_type = "volume" -> null
          - tags          = {
              - "Name"      = "iac-dev-ec2"
              - "Namespace" = "iac"
              - "Owner"     = "Terraform"
              - "Stage"     = "dev"
              - "Tier"      = "1"
            } -> null
        }
      - tag_specifications {
          - resource_type = "instance" -> null
          - tags          = {
              - "Name"      = "iac-dev-ec2"
              - "Namespace" = "iac"
              - "Owner"     = "Terraform"
              - "Stage"     = "dev"
              - "Tier"      = "1"
            } -> null
        }
    }

  # module.rds_cluster.aws_db_parameter_group.default[0] will be destroyed
  - resource "aws_db_parameter_group" "default" {
      - arn         = "arn:aws:rds:us-west-2:662028814455:pg:iac-dev-rds" -> null
      - description = "DB instance parameter group" -> null
      - family      = "aurora-postgresql10" -> null
      - id          = "iac-dev-rds" -> null
      - name        = "iac-dev-rds" -> null
      - tags        = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
    }

  # module.rds_cluster.aws_db_subnet_group.default[0] will be destroyed
  - resource "aws_db_subnet_group" "default" {
      - arn         = "arn:aws:rds:us-west-2:662028814455:subgrp:iac-dev-rds" -> null
      - description = "Allowed subnets for DB cluster instances" -> null
      - id          = "iac-dev-rds" -> null
      - name        = "iac-dev-rds" -> null
      - subnet_ids  = [
          - "subnet-01f68a89a048e7ca7",
          - "subnet-06460b59759808ae6",
          - "subnet-091cb53cde2f5a18b",
        ] -> null
      - tags        = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
    }

  # module.rds_cluster.aws_rds_cluster.default[0] will be destroyed
  - resource "aws_rds_cluster" "default" {
      - apply_immediately                   = true -> null
      - arn                                 = "arn:aws:rds:us-west-2:662028814455:cluster:iac-dev-rds" -> null
      - availability_zones                  = [
          - "us-west-2a",
          - "us-west-2b",
          - "us-west-2c",
        ] -> null
      - backtrack_window                    = 0 -> null
      - backup_retention_period             = 5 -> null
      - cluster_identifier                  = "iac-dev-rds" -> null
      - cluster_members                     = [
          - "iac-dev-rds-1",
        ] -> null
      - cluster_resource_id                 = "cluster-7NOHF6EQAQ7IOA6WAQKJ7KA2AM" -> null
      - copy_tags_to_snapshot               = false -> null
      - database_name                       = "iac_db" -> null
      - db_cluster_parameter_group_name     = "iac-dev-rds" -> null
      - db_subnet_group_name                = "iac-dev-rds" -> null
      - deletion_protection                 = false -> null
      - enable_http_endpoint                = false -> null
      - enabled_cloudwatch_logs_exports     = [] -> null
      - endpoint                            = "iac-dev-rds.cluster-ceiofvzcgozo.us-west-2.rds.amazonaws.com" -> null
      - engine                              = "aurora-postgresql" -> null
      - engine_mode                         = "provisioned" -> null
      - engine_version                      = "10.7" -> null
      - final_snapshot_identifier           = "iac-dev-rds" -> null
      - hosted_zone_id                      = "Z1PVIF0B656C1W" -> null
      - iam_database_authentication_enabled = false -> null
      - iam_roles                           = [] -> null
      - id                                  = "iac-dev-rds" -> null
      - master_password                     = (sensitive value)
      - master_username                     = "adminrds" -> null
      - port                                = 5432 -> null
      - preferred_backup_window             = "07:00-09:00" -> null
      - preferred_maintenance_window        = "wed:03:00-wed:04:00" -> null
      - reader_endpoint                     = "iac-dev-rds.cluster-ro-ceiofvzcgozo.us-west-2.rds.amazonaws.com" -> null
      - skip_final_snapshot                 = true -> null
      - storage_encrypted                   = false -> null
      - tags                                = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
      - vpc_security_group_ids              = [
          - "sg-0a5f58ec1536230f7",
        ] -> null
    }

  # module.rds_cluster.aws_rds_cluster_instance.default[0] will be destroyed
  - resource "aws_rds_cluster_instance" "default" {
      - arn                          = "arn:aws:rds:us-west-2:662028814455:db:iac-dev-rds-1" -> null
      - auto_minor_version_upgrade   = true -> null
      - availability_zone            = "us-west-2a" -> null
      - ca_cert_identifier           = "rds-ca-2019" -> null
      - cluster_identifier           = "iac-dev-rds" -> null
      - copy_tags_to_snapshot        = false -> null
      - db_parameter_group_name      = "iac-dev-rds" -> null
      - db_subnet_group_name         = "iac-dev-rds" -> null
      - dbi_resource_id              = "db-ENQKWTV7O2IVTQUWZCYS7OLHHE" -> null
      - endpoint                     = "iac-dev-rds-1.ceiofvzcgozo.us-west-2.rds.amazonaws.com" -> null
      - engine                       = "aurora-postgresql" -> null
      - engine_version               = "10.7" -> null
      - id                           = "iac-dev-rds-1" -> null
      - identifier                   = "iac-dev-rds-1" -> null
      - instance_class               = "db.r4.large" -> null
      - monitoring_interval          = 0 -> null
      - performance_insights_enabled = false -> null
      - port                         = 5432 -> null
      - preferred_backup_window      = "07:00-09:00" -> null
      - preferred_maintenance_window = "sun:11:52-sun:12:22" -> null
      - promotion_tier               = 0 -> null
      - publicly_accessible          = false -> null
      - storage_encrypted            = false -> null
      - tags                         = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
      - writer                       = true -> null
    }

  # module.rds_cluster.aws_rds_cluster_parameter_group.default[0] will be destroyed
  - resource "aws_rds_cluster_parameter_group" "default" {
      - arn         = "arn:aws:rds:us-west-2:662028814455:cluster-pg:iac-dev-rds" -> null
      - description = "DB cluster parameter group" -> null
      - family      = "aurora-postgresql10" -> null
      - id          = "iac-dev-rds" -> null
      - name        = "iac-dev-rds" -> null
      - tags        = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
    }

  # module.rds_cluster.aws_security_group.default[0] will be destroyed
  - resource "aws_security_group" "default" {
      - arn                    = "arn:aws:ec2:us-west-2:662028814455:security-group/sg-0a5f58ec1536230f7" -> null
      - description            = "Allow inbound traffic from Security Groups and CIDRs" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0a5f58ec1536230f7" -> null
      - ingress                = [
          - {
              - cidr_blocks      = []
              - description      = ""
              - from_port        = 3306
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = [
                  - "sg-091cd0f41fce76446",
                ]
              - self             = false
              - to_port          = 3306
            },
          - {
              - cidr_blocks      = []
              - description      = ""
              - from_port        = 3306
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 3306
            },
        ] -> null
      - name                   = "iac-dev-rds" -> null
      - owner_id               = "662028814455" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name"      = "iac-dev-rds"
          - "Namespace" = "iac"
          - "Stage"     = "dev"
        } -> null
      - vpc_id                 = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_eip.default[0] will be destroyed
  - resource "aws_eip" "default" {
      - association_id    = "eipassoc-0949e2684ec14424e" -> null
      - domain            = "vpc" -> null
      - id                = "eipalloc-0ee98473a1c471528" -> null
      - network_interface = "eni-04fbe758a7183edca" -> null
      - private_dns       = "ip-10-0-141-119.us-west-2.compute.internal" -> null
      - private_ip        = "10.0.141.119" -> null
      - public_dns        = "ec2-54-218-220-65.us-west-2.compute.amazonaws.com" -> null
      - public_ip         = "54.218.220.65" -> null
      - public_ipv4_pool  = "amazon" -> null
      - tags              = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2a"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc               = true -> null
    }

  # module.subnets.aws_eip.default[1] will be destroyed
  - resource "aws_eip" "default" {
      - association_id    = "eipassoc-03ae6e76705d51cb3" -> null
      - domain            = "vpc" -> null
      - id                = "eipalloc-0ea37feffa5670376" -> null
      - network_interface = "eni-0c7251d7911f149f7" -> null
      - private_dns       = "ip-10-0-175-152.us-west-2.compute.internal" -> null
      - private_ip        = "10.0.175.152" -> null
      - public_dns        = "ec2-44-233-5-36.us-west-2.compute.amazonaws.com" -> null
      - public_ip         = "44.233.5.36" -> null
      - public_ipv4_pool  = "amazon" -> null
      - tags              = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2b"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc               = true -> null
    }

  # module.subnets.aws_eip.default[2] will be destroyed
  - resource "aws_eip" "default" {
      - association_id    = "eipassoc-0e8dc8e951e455ed7" -> null
      - domain            = "vpc" -> null
      - id                = "eipalloc-0c9ebae8a02b3add0" -> null
      - network_interface = "eni-05c041168248dc0de" -> null
      - private_dns       = "ip-10-0-206-43.us-west-2.compute.internal" -> null
      - private_ip        = "10.0.206.43" -> null
      - public_dns        = "ec2-44-233-131-226.us-west-2.compute.amazonaws.com" -> null
      - public_ip         = "44.233.131.226" -> null
      - public_ipv4_pool  = "amazon" -> null
      - tags              = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2c"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc               = true -> null
    }

  # module.subnets.aws_nat_gateway.default[0] will be destroyed
  - resource "aws_nat_gateway" "default" {
      - allocation_id        = "eipalloc-0ee98473a1c471528" -> null
      - id                   = "nat-0893089d49c77ee11" -> null
      - network_interface_id = "eni-04fbe758a7183edca" -> null
      - private_ip           = "10.0.141.119" -> null
      - public_ip            = "54.218.220.65" -> null
      - subnet_id            = "subnet-09e4e142936b2d83a" -> null
      - tags                 = {
          - "Attributes" = "nat"
          - "Name"       = "iac-dev-ecp-nat-us-west-2a"
          - "Namespace"  = "iac"
          - "Stage"      = "dev"
        } -> null
    }

  # module.subnets.aws_nat_gateway.default[1] will be destroyed
  - resource "aws_nat_gateway" "default" {
      - allocation_id        = "eipalloc-0ea37feffa5670376" -> null
      - id                   = "nat-0622789960bb7daa0" -> null
      - network_interface_id = "eni-0c7251d7911f149f7" -> null
      - private_ip           = "10.0.175.152" -> null
      - public_ip            = "44.233.5.36" -> null
      - subnet_id            = "subnet-023871b75b6bbbb8d" -> null
      - tags                 = {
          - "Attributes" = "nat"
          - "Name"       = "iac-dev-ecp-nat-us-west-2b"
          - "Namespace"  = "iac"
          - "Stage"      = "dev"
        } -> null
    }

  # module.subnets.aws_nat_gateway.default[2] will be destroyed
  - resource "aws_nat_gateway" "default" {
      - allocation_id        = "eipalloc-0c9ebae8a02b3add0" -> null
      - id                   = "nat-06ba0fed9a127dbc1" -> null
      - network_interface_id = "eni-05c041168248dc0de" -> null
      - private_ip           = "10.0.206.43" -> null
      - public_ip            = "44.233.131.226" -> null
      - subnet_id            = "subnet-01ba667d8ecf13479" -> null
      - tags                 = {
          - "Attributes" = "nat"
          - "Name"       = "iac-dev-ecp-nat-us-west-2c"
          - "Namespace"  = "iac"
          - "Stage"      = "dev"
        } -> null
    }

  # module.subnets.aws_network_acl.private[0] will be destroyed
  - resource "aws_network_acl" "private" {
      - egress     = [
          - {
              - action          = "allow"
              - cidr_block      = "0.0.0.0/0"
              - from_port       = 0
              - icmp_code       = 0
              - icmp_type       = 0
              - ipv6_cidr_block = ""
              - protocol        = "-1"
              - rule_no         = 100
              - to_port         = 0
            },
        ] -> null
      - id         = "acl-0037a6c512b9ea029" -> null
      - ingress    = [
          - {
              - action          = "allow"
              - cidr_block      = "0.0.0.0/0"
              - from_port       = 0
              - icmp_code       = 0
              - icmp_type       = 0
              - ipv6_cidr_block = ""
              - protocol        = "-1"
              - rule_no         = 100
              - to_port         = 0
            },
        ] -> null
      - owner_id   = "662028814455" -> null
      - subnet_ids = [
          - "subnet-01f68a89a048e7ca7",
          - "subnet-06460b59759808ae6",
          - "subnet-091cb53cde2f5a18b",
        ] -> null
      - tags       = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-subnet"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id     = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_network_acl.public[0] will be destroyed
  - resource "aws_network_acl" "public" {
      - egress     = [
          - {
              - action          = "allow"
              - cidr_block      = "0.0.0.0/0"
              - from_port       = 0
              - icmp_code       = 0
              - icmp_type       = 0
              - ipv6_cidr_block = ""
              - protocol        = "-1"
              - rule_no         = 100
              - to_port         = 0
            },
        ] -> null
      - id         = "acl-098887751d5dd5b90" -> null
      - ingress    = [
          - {
              - action          = "allow"
              - cidr_block      = "0.0.0.0/0"
              - from_port       = 0
              - icmp_code       = 0
              - icmp_type       = 0
              - ipv6_cidr_block = ""
              - protocol        = "-1"
              - rule_no         = 100
              - to_port         = 0
            },
        ] -> null
      - owner_id   = "662028814455" -> null
      - subnet_ids = [
          - "subnet-01ba667d8ecf13479",
          - "subnet-023871b75b6bbbb8d",
          - "subnet-09e4e142936b2d83a",
        ] -> null
      - tags       = {
          - "Attributes"          = "public"
          - "Name"                = "iac-dev-subnet"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "public"
        } -> null
      - vpc_id     = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_route.default[0] will be destroyed
  - resource "aws_route" "default" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - id                     = "r-rtb-0412971a9a2b0af171080289494" -> null
      - nat_gateway_id         = "nat-0893089d49c77ee11" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-0412971a9a2b0af17" -> null
      - state                  = "active" -> null
    }

  # module.subnets.aws_route.default[1] will be destroyed
  - resource "aws_route" "default" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - id                     = "r-rtb-0514727ce29bf5a411080289494" -> null
      - nat_gateway_id         = "nat-0622789960bb7daa0" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-0514727ce29bf5a41" -> null
      - state                  = "active" -> null
    }

  # module.subnets.aws_route.default[2] will be destroyed
  - resource "aws_route" "default" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - id                     = "r-rtb-0626bed08312317061080289494" -> null
      - nat_gateway_id         = "nat-06ba0fed9a127dbc1" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-0626bed0831231706" -> null
      - state                  = "active" -> null
    }

  # module.subnets.aws_route.public[0] will be destroyed
  - resource "aws_route" "public" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - gateway_id             = "igw-055161e27697962d5" -> null
      - id                     = "r-rtb-025bbe4df51dea0651080289494" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-025bbe4df51dea065" -> null
      - state                  = "active" -> null
    }

  # module.subnets.aws_route_table.private[0] will be destroyed
  - resource "aws_route_table" "private" {
      - id               = "rtb-0412971a9a2b0af17" -> null
      - owner_id         = "662028814455" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                = "0.0.0.0/0"
              - egress_only_gateway_id    = ""
              - gateway_id                = ""
              - instance_id               = ""
              - ipv6_cidr_block           = ""
              - nat_gateway_id            = "nat-0893089d49c77ee11"
              - network_interface_id      = ""
              - transit_gateway_id        = ""
              - vpc_peering_connection_id = ""
            },
        ] -> null
      - tags             = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2a"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id           = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_route_table.private[1] will be destroyed
  - resource "aws_route_table" "private" {
      - id               = "rtb-0514727ce29bf5a41" -> null
      - owner_id         = "662028814455" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                = "0.0.0.0/0"
              - egress_only_gateway_id    = ""
              - gateway_id                = ""
              - instance_id               = ""
              - ipv6_cidr_block           = ""
              - nat_gateway_id            = "nat-0622789960bb7daa0"
              - network_interface_id      = ""
              - transit_gateway_id        = ""
              - vpc_peering_connection_id = ""
            },
        ] -> null
      - tags             = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2b"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id           = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_route_table.private[2] will be destroyed
  - resource "aws_route_table" "private" {
      - id               = "rtb-0626bed0831231706" -> null
      - owner_id         = "662028814455" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                = "0.0.0.0/0"
              - egress_only_gateway_id    = ""
              - gateway_id                = ""
              - instance_id               = ""
              - ipv6_cidr_block           = ""
              - nat_gateway_id            = "nat-06ba0fed9a127dbc1"
              - network_interface_id      = ""
              - transit_gateway_id        = ""
              - vpc_peering_connection_id = ""
            },
        ] -> null
      - tags             = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2c"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id           = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_route_table.public[0] will be destroyed
  - resource "aws_route_table" "public" {
      - id               = "rtb-025bbe4df51dea065" -> null
      - owner_id         = "662028814455" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                = "0.0.0.0/0"
              - egress_only_gateway_id    = ""
              - gateway_id                = "igw-055161e27697962d5"
              - instance_id               = ""
              - ipv6_cidr_block           = ""
              - nat_gateway_id            = ""
              - network_interface_id      = ""
              - transit_gateway_id        = ""
              - vpc_peering_connection_id = ""
            },
        ] -> null
      - tags             = {
          - "Attributes"          = "public"
          - "Name"                = "iac-dev-subnet"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "public"
        } -> null
      - vpc_id           = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_route_table_association.private[0] will be destroyed
  - resource "aws_route_table_association" "private" {
      - id             = "rtbassoc-0b2140ea42b1b8b3c" -> null
      - route_table_id = "rtb-0412971a9a2b0af17" -> null
      - subnet_id      = "subnet-06460b59759808ae6" -> null
    }

  # module.subnets.aws_route_table_association.private[1] will be destroyed
  - resource "aws_route_table_association" "private" {
      - id             = "rtbassoc-09b1c565668e1380e" -> null
      - route_table_id = "rtb-0514727ce29bf5a41" -> null
      - subnet_id      = "subnet-01f68a89a048e7ca7" -> null
    }

  # module.subnets.aws_route_table_association.private[2] will be destroyed
  - resource "aws_route_table_association" "private" {
      - id             = "rtbassoc-0bd3af89d44c3ab6e" -> null
      - route_table_id = "rtb-0626bed0831231706" -> null
      - subnet_id      = "subnet-091cb53cde2f5a18b" -> null
    }

  # module.subnets.aws_route_table_association.public[0] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0b9bc963f27a64293" -> null
      - route_table_id = "rtb-025bbe4df51dea065" -> null
      - subnet_id      = "subnet-09e4e142936b2d83a" -> null
    }

  # module.subnets.aws_route_table_association.public[1] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0dca805f0d16a0148" -> null
      - route_table_id = "rtb-025bbe4df51dea065" -> null
      - subnet_id      = "subnet-023871b75b6bbbb8d" -> null
    }

  # module.subnets.aws_route_table_association.public[2] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0a6dfb6e2a6e399ec" -> null
      - route_table_id = "rtb-025bbe4df51dea065" -> null
      - subnet_id      = "subnet-01ba667d8ecf13479" -> null
    }

  # module.subnets.aws_subnet.private[0] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-06460b59759808ae6" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2a" -> null
      - availability_zone_id            = "usw2-az1" -> null
      - cidr_block                      = "10.0.0.0/19" -> null
      - id                              = "subnet-06460b59759808ae6" -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2a"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_subnet.private[1] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-01f68a89a048e7ca7" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2b" -> null
      - availability_zone_id            = "usw2-az2" -> null
      - cidr_block                      = "10.0.32.0/19" -> null
      - id                              = "subnet-01f68a89a048e7ca7" -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2b"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_subnet.private[2] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-091cb53cde2f5a18b" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2c" -> null
      - availability_zone_id            = "usw2-az3" -> null
      - cidr_block                      = "10.0.64.0/19" -> null
      - id                              = "subnet-091cb53cde2f5a18b" -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "private"
          - "Name"                = "iac-dev-ecp-private-us-west-2c"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "private"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_subnet.public[0] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-09e4e142936b2d83a" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2a" -> null
      - availability_zone_id            = "usw2-az1" -> null
      - cidr_block                      = "10.0.128.0/19" -> null
      - id                              = "subnet-09e4e142936b2d83a" -> null
      - map_public_ip_on_launch         = true -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "public"
          - "Name"                = "iac-dev-ecp-public-us-west-2a"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "public"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_subnet.public[1] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-023871b75b6bbbb8d" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2b" -> null
      - availability_zone_id            = "usw2-az2" -> null
      - cidr_block                      = "10.0.160.0/19" -> null
      - id                              = "subnet-023871b75b6bbbb8d" -> null
      - map_public_ip_on_launch         = true -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "public"
          - "Name"                = "iac-dev-ecp-public-us-west-2b"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "public"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.subnets.aws_subnet.public[2] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                             = "arn:aws:ec2:us-west-2:662028814455:subnet/subnet-01ba667d8ecf13479" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-west-2c" -> null
      - availability_zone_id            = "usw2-az3" -> null
      - cidr_block                      = "10.0.192.0/19" -> null
      - id                              = "subnet-01ba667d8ecf13479" -> null
      - map_public_ip_on_launch         = true -> null
      - owner_id                        = "662028814455" -> null
      - tags                            = {
          - "Attributes"          = "public"
          - "Name"                = "iac-dev-ecp-public-us-west-2c"
          - "Namespace"           = "iac"
          - "Stage"               = "dev"
          - "cpco.io/subnet/type" = "public"
        } -> null
      - vpc_id                          = "vpc-06930f221f81bb801" -> null
    }

  # module.vpc.aws_default_security_group.default will be destroyed
  - resource "aws_default_security_group" "default" {
      - arn                    = "arn:aws:ec2:us-west-2:662028814455:security-group/sg-031783e2203d3d78f" -> null
      - egress                 = [] -> null
      - id                     = "sg-031783e2203d3d78f" -> null
      - ingress                = [] -> null
      - name                   = "default" -> null
      - owner_id               = "662028814455" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "Default Security Group"
        } -> null
      - vpc_id                 = "vpc-06930f221f81bb801" -> null
    }

  # module.vpc.aws_internet_gateway.default will be destroyed
  - resource "aws_internet_gateway" "default" {
      - id       = "igw-055161e27697962d5" -> null
      - owner_id = "662028814455" -> null
      - tags     = {
          - "Name"      = "iac-dev-vpc"
          - "Namespace" = "iac"
          - "Owner"     = "Terraform"
          - "Stage"     = "dev"
        } -> null
      - vpc_id   = "vpc-06930f221f81bb801" -> null
    }

  # module.vpc.aws_vpc.default will be destroyed
  - resource "aws_vpc" "default" {
      - arn                              = "arn:aws:ec2:us-west-2::vpc/vpc-06930f221f81bb801" -> null
      - assign_generated_ipv6_cidr_block = true -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-0a533d7a6677cc7a0" -> null
      - default_route_table_id           = "rtb-07bd700659912d610" -> null
      - default_security_group_id        = "sg-031783e2203d3d78f" -> null
      - dhcp_options_id                  = "dopt-0ac8a75cb3483c1d8" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = true -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-06930f221f81bb801" -> null
      - instance_tenancy                 = "default" -> null
      - ipv6_association_id              = "vpc-cidr-assoc-03e40502883e187d5" -> null
      - ipv6_cidr_block                  = "2600:1f14:2a7:4200::/56" -> null
      - main_route_table_id              = "rtb-07bd700659912d610" -> null
      - owner_id                         = "662028814455" -> null
      - tags                             = {
          - "Name"      = "iac-dev-vpc"
          - "Namespace" = "iac"
          - "Owner"     = "Terraform"
          - "Stage"     = "dev"
        } -> null
    }

Plan: 0 to add, 0 to change, 60 to destroy.

------------------------------------------------------------------------

This plan was saved to: ./destroy/iac-cluster.destroy

To perform exactly these actions, run the following command to apply:
    terraform apply "./destroy/iac-cluster.destroy"
```

```
$ terraform apply "./destroy/iac-cluster.destroy"
```

```yaml
 terraform apply "./destroy/iac-cluster.destroy"
module.aws_key_pair.null_resource.chmod[0]: Destroying... [id=9145674845761086373]
module.aws_key_pair.local_file.public_key_openssh[0]: Destroying... [id=76b45103a42dfd5ea48cf78e43c571ba3835662d]
module.aws_key_pair.null_resource.chmod[0]: Destruction complete after 0s
module.aws_key_pair.local_file.public_key_openssh[0]: Destruction complete after 0s
module.subnets.aws_network_acl.public[0]: Destroying... [id=acl-098887751d5dd5b90]
aws_security_group_rule.rds_ingress[0]: Destroying... [id=sgrule-2269282911]
module.vpc.aws_default_security_group.default: Destroying... [id=sg-031783e2203d3d78f]
aws_security_group_rule.ingress[1]: Destroying... [id=sgrule-631296820]
module.subnets.aws_route.default[0]: Destroying... [id=r-rtb-0412971a9a2b0af171080289494]
module.vpc.aws_default_security_group.default: Destruction complete after 0s
aws_security_group_rule.ingress[0]: Destroying... [id=sgrule-2469039745]
aws_security_group_rule.ingress[2]: Destroying... [id=sgrule-3233341605]
module.subnets.aws_route_table_association.public[2]: Destroying... [id=rtbassoc-0a6dfb6e2a6e399ec]
aws_security_group_rule.ingress[3]: Destroying... [id=sgrule-47396811]
module.subnets.aws_route.default[1]: Destroying... [id=r-rtb-0514727ce29bf5a411080289494]
module.subnets.aws_route.default[2]: Destroying... [id=r-rtb-0626bed08312317061080289494]
module.subnets.aws_route.default[0]: Destruction complete after 1s
module.subnets.aws_route.default[1]: Destruction complete after 1s
module.subnets.aws_route_table_association.public[2]: Destruction complete after 1s
module.subnets.aws_route_table_association.private[0]: Destroying... [id=rtbassoc-0b2140ea42b1b8b3c]
module.subnets.aws_route_table_association.public[1]: Destroying... [id=rtbassoc-0dca805f0d16a0148]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Destroying... [id=iac-dev-rds-1]
module.subnets.aws_route.default[2]: Destruction complete after 1s
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Destroying... [id=iac-dev-ec2-asg-cpu-utilization-low]
aws_security_group_rule.rds_ingress[0]: Destruction complete after 1s
aws_security_group_rule.ingress[1]: Destruction complete after 1s
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Destroying... [id=iac-dev-ec2-asg-cpu-utilization-high]
aws_security_group_rule.rds_ingress[1]: Destroying... [id=sgrule-1111972389]
module.subnets.aws_route_table_association.public[1]: Destruction complete after 0s
module.subnets.aws_route_table_association.private[0]: Destruction complete after 0s
aws_security_group_rule.rds_egress[0]: Destroying... [id=sgrule-3431259760]
aws_security_group_rule.egress[0]: Destroying... [id=sgrule-1417906670]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Destruction complete after 1s
module.subnets.aws_route_table_association.private[2]: Destroying... [id=rtbassoc-0bd3af89d44c3ab6e]
aws_security_group_rule.rds_ingress[1]: Destruction complete after 1s
module.subnets.aws_route.public[0]: Destroying... [id=r-rtb-025bbe4df51dea0651080289494]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Destruction complete after 1s
module.subnets.aws_network_acl.private[0]: Destroying... [id=acl-0037a6c512b9ea029]
module.subnets.aws_route_table_association.private[2]: Destruction complete after 5s
module.subnets.aws_route_table_association.private[1]: Destroying... [id=rtbassoc-09b1c565668e1380e]
module.subnets.aws_route.public[0]: Destruction complete after 5s
module.subnets.aws_route_table_association.public[0]: Destroying... [id=rtbassoc-0b9bc963f27a64293]
aws_security_group_rule.ingress[0]: Destruction complete after 7s
aws_security_group_rule.rds_ingress_dynamic[0]: Destroying... [id=sgrule-214679645]
aws_security_group_rule.rds_egress[0]: Destruction complete after 6s
module.aws_key_pair.local_file.private_key_pem[0]: Destroying... [id=3aafbae020fc12f3acbdfce253f61a716013ed4c]
module.aws_key_pair.local_file.private_key_pem[0]: Destruction complete after 0s
module.subnets.aws_nat_gateway.default[2]: Destroying... [id=nat-06ba0fed9a127dbc1]
module.subnets.aws_network_acl.public[0]: Still destroying... [id=acl-098887751d5dd5b90, 10s elapsed]
aws_security_group_rule.ingress[2]: Still destroying... [id=sgrule-3233341605, 10s elapsed]
aws_security_group_rule.ingress[3]: Still destroying... [id=sgrule-47396811, 10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 10s elapsed]
aws_security_group_rule.egress[0]: Still destroying... [id=sgrule-1417906670, 10s elapsed]
module.subnets.aws_network_acl.private[0]: Still destroying... [id=acl-0037a6c512b9ea029, 10s elapsed]
module.subnets.aws_route_table_association.public[0]: Destruction complete after 5s
module.subnets.aws_nat_gateway.default[0]: Destroying... [id=nat-0893089d49c77ee11]
module.subnets.aws_route_table_association.private[1]: Destruction complete after 5s
module.subnets.aws_nat_gateway.default[1]: Destroying... [id=nat-0622789960bb7daa0]
aws_security_group_rule.rds_ingress_dynamic[0]: Destruction complete after 5s
aws_security_group_rule.ingress[2]: Destruction complete after 12s
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Destroying... [id=iac-dev-ec2-asg-scale-up]
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Destroying... [id=iac-dev-ec2-asg-scale-down]
aws_security_group_rule.ingress[3]: Destruction complete after 13s
module.vpc.aws_internet_gateway.default: Destroying... [id=igw-055161e27697962d5]
module.subnets.aws_network_acl.public[0]: Destruction complete after 13s
module.subnets.aws_route_table.public[0]: Destroying... [id=rtb-025bbe4df51dea065]
aws_security_group_rule.egress[0]: Destruction complete after 13s
module.subnets.aws_route_table.private[0]: Destroying... [id=rtb-0412971a9a2b0af17]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 10s elapsed]
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Destruction complete after 6s
module.subnets.aws_route_table.private[2]: Destroying... [id=rtb-0626bed0831231706]
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Destruction complete after 6s
module.subnets.aws_route_table.private[1]: Destroying... [id=rtb-0514727ce29bf5a41]
module.subnets.aws_route_table.public[0]: Destruction complete after 6s
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Destroying... [id=iac-dev-ec2-asg-20200210203901665700000003]
module.subnets.aws_route_table.private[0]: Destruction complete after 5s
module.subnets.aws_route_table.private[1]: Destruction complete after 1s
module.subnets.aws_route_table.private[2]: Destruction complete after 1s
module.subnets.aws_network_acl.private[0]: Destruction complete after 18s
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 20s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still destroying... [id=nat-0893089d49c77ee11, 10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 10s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 20s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 30s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still destroying... [id=nat-0893089d49c77ee11, 20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 20s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 30s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 40s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still destroying... [id=nat-0893089d49c77ee11, 30s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 30s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 30s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 40s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 50s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still destroying... [id=nat-0893089d49c77ee11, 40s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 40s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 40s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 50s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m0s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still destroying... [id=nat-0893089d49c77ee11, 50s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 50s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 50s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still destroying... [id=nat-06ba0fed9a127dbc1, 1m0s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 50s elapsed]
module.subnets.aws_nat_gateway.default[2]: Destruction complete after 1m2s
module.subnets.aws_nat_gateway.default[0]: Destruction complete after 57s
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 1m0s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m0s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 1m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still destroying... [id=nat-0622789960bb7daa0, 1m10s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m10s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 1m10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Destruction complete after 1m18s
module.subnets.aws_eip.default[2]: Destroying... [id=eipalloc-0c9ebae8a02b3add0]
module.subnets.aws_eip.default[0]: Destroying... [id=eipalloc-0ee98473a1c471528]
module.subnets.aws_eip.default[1]: Destroying... [id=eipalloc-0ea37feffa5670376]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m30s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m20s elapsed]
module.subnets.aws_eip.default[0]: Destruction complete after 6s
module.subnets.aws_eip.default[1]: Destruction complete after 6s
module.subnets.aws_eip.default[2]: Destruction complete after 6s
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 1m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m40s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m30s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 1m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 1m50s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m40s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still destroying... [id=iac-dev-ec2-asg-20200210203901665700000003, 1m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m0s elapsed]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 1m50s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Destruction complete after 1m48s
aws_elb.iac-dev-asg-elb: Destroying... [id=iac-dev-asg-elb]
module.iac-dev-ecp.aws_launch_template.default[0]: Destroying... [id=lt-0a2928df81bb94676]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m10s elapsed]
module.iac-dev-ecp.aws_launch_template.default[0]: Destruction complete after 5s
module.aws_key_pair.aws_key_pair.generated[0]: Destroying... [id=iac-dev-jeffrymilan]
module.aws_key_pair.aws_key_pair.generated[0]: Destruction complete after 0s
module.aws_key_pair.tls_private_key.default[0]: Destroying... [id=1af8cdb01a0d33950630bf133e6aff7628283d38]
module.aws_key_pair.tls_private_key.default[0]: Destruction complete after 0s
aws_elb.iac-dev-asg-elb: Destruction complete after 6s
module.subnets.aws_subnet.public[0]: Destroying... [id=subnet-09e4e142936b2d83a]
module.subnets.aws_subnet.public[1]: Destroying... [id=subnet-023871b75b6bbbb8d]
module.subnets.aws_subnet.public[2]: Destroying... [id=subnet-01ba667d8ecf13479]
aws_security_group.iac-dev-ec2-sg: Destroying... [id=sg-0f202a554030214fb]
module.vpc.aws_internet_gateway.default: Still destroying... [id=igw-055161e27697962d5, 2m0s elapsed]
module.subnets.aws_subnet.public[2]: Destruction complete after 0s
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m20s elapsed]
module.subnets.aws_subnet.public[0]: Destruction complete after 8s
module.subnets.aws_subnet.public[1]: Destruction complete after 8s
aws_security_group.iac-dev-ec2-sg: Destruction complete after 9s
module.vpc.aws_internet_gateway.default: Destruction complete after 2m10s
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 2m50s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 3m0s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 3m10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 3m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 3m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still destroying... [id=iac-dev-rds-1, 3m40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Destruction complete after 3m47s
module.rds_cluster.aws_db_parameter_group.default[0]: Destroying... [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster.default[0]: Destroying... [id=iac-dev-rds]
module.rds_cluster.aws_db_parameter_group.default[0]: Destruction complete after 0s
module.rds_cluster.aws_rds_cluster.default[0]: Still destroying... [id=iac-dev-rds, 10s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still destroying... [id=iac-dev-rds, 20s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still destroying... [id=iac-dev-rds, 30s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still destroying... [id=iac-dev-rds, 40s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still destroying... [id=iac-dev-rds, 50s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Destruction complete after 51s
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Destroying... [id=iac-dev-rds]
module.rds_cluster.aws_db_subnet_group.default[0]: Destroying... [id=iac-dev-rds]
module.rds_cluster.aws_security_group.default[0]: Destroying... [id=sg-0a5f58ec1536230f7]
module.rds_cluster.aws_db_subnet_group.default[0]: Destruction complete after 0s
module.subnets.aws_subnet.private[2]: Destroying... [id=subnet-091cb53cde2f5a18b]
module.subnets.aws_subnet.private[0]: Destroying... [id=subnet-06460b59759808ae6]
module.subnets.aws_subnet.private[1]: Destroying... [id=subnet-01f68a89a048e7ca7]
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Destruction complete after 0s
module.rds_cluster.aws_security_group.default[0]: Destruction complete after 0s
aws_security_group.iac-dev-rds-sg: Destroying... [id=sg-091cd0f41fce76446]
module.subnets.aws_subnet.private[2]: Destruction complete after 1s
module.subnets.aws_subnet.private[0]: Destruction complete after 1s
module.subnets.aws_subnet.private[1]: Destruction complete after 1s
aws_security_group.iac-dev-rds-sg: Destruction complete after 6s
module.vpc.aws_vpc.default: Destroying... [id=vpc-06930f221f81bb801]
module.vpc.aws_vpc.default: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 60 destroyed.

Outputs:

arn = 
autoscaling_group_arn = 
autoscaling_group_default_cooldown = 
autoscaling_group_desired_capacity = 
autoscaling_group_health_check_grace_period = 
autoscaling_group_health_check_type = 
autoscaling_group_id = 
autoscaling_group_max_size = 
autoscaling_group_min_size = 
autoscaling_group_name = 
cluster_identifier = 
cluster_resource_id = 
database_name = 
dbi_resource_ids = []
endpoint = 
launch_template_arn = 
launch_template_id = 
master_host = 
master_username = 
private_subnet_cidrs = []
public_subnet_cidrs = []
reader_endpoint = 
replicas_host =
```



### END - Thank you.