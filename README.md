
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
$ terraform init

Initializing modules...
...truncated
Initializing the backend...
...truncated
Initializing provider plugins...
...truncated
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Terraform Plan (dry-run)
```yaml
$ terraform plan -var-file=iac-cluster.tfvars -out=./plan/iac-cluster.plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_instance_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.private_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.public_label.data.null_data_source.tags_as_list_of_maps[4]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
module.subnets.module.nat_label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[1]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[3]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[2]: Refreshing state...
module.vpc.module.label.data.null_data_source.tags_as_list_of_maps[0]: Refreshing state...
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
      + key_name    = "iac-dev-iac-cluster"
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
    }

  # module.aws_key_pair.local_file.private_key_pem[0] will be created
  + resource "local_file" "private_key_pem" {
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./secrets/iac-dev-iac-cluster"
      + id                   = (known after apply)
      + sensitive_content    = (sensitive value)
    }

  # module.aws_key_pair.local_file.public_key_openssh[0] will be created
  + resource "local_file" "public_key_openssh" {
      + content              = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./secrets/iac-dev-iac-cluster.pub"
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
      + key_name                             = "iac-dev-iac-cluster"
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
```yaml
$ terraform apply "./plan/iac-cluster.plan"

module.aws_key_pair.tls_private_key.default[0]: Creating...
module.aws_key_pair.tls_private_key.default[0]: Creation complete after 0s [id=cbb38f9c1ee403bf344db9782d898e7736584232]
module.subnets.aws_eip.default[1]: Creating...
module.subnets.aws_eip.default[2]: Creating...
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Creating...
module.subnets.aws_eip.default[0]: Creating...
module.aws_key_pair.local_file.public_key_openssh[0]: Creating...
module.aws_key_pair.local_file.private_key_pem[0]: Creating...
module.rds_cluster.aws_db_parameter_group.default[0]: Creating...
module.aws_key_pair.aws_key_pair.generated[0]: Creating...
module.aws_key_pair.local_file.public_key_openssh[0]: Creation complete after 0s [id=123995bce3cb822a4558445a36fabe719a5b925c]
module.aws_key_pair.local_file.private_key_pem[0]: Creation complete after 0s [id=122d0f236241c650f3139119b769fba7da9077c8]
module.vpc.aws_vpc.default: Creating...
module.aws_key_pair.null_resource.chmod[0]: Creating...
module.aws_key_pair.null_resource.chmod[0]: Provisioning with 'local-exec'...
module.aws_key_pair.null_resource.chmod[0] (local-exec): Executing: ["/bin/sh" "-c" "chmod 600 ./secrets/iac-dev-iac-cluster"]
module.aws_key_pair.null_resource.chmod[0]: Creation complete after 0s [id=1429066280363734842]
module.aws_key_pair.aws_key_pair.generated[0]: Creation complete after 1s [id=iac-dev-iac-cluster]
module.subnets.aws_eip.default[1]: Creation complete after 6s [id=eipalloc-0680e6f9bda0a8d19]
module.rds_cluster.aws_db_parameter_group.default[0]: Still creating... [10s elapsed]
module.subnets.aws_eip.default[0]: Still creating... [10s elapsed]
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Still creating... [10s elapsed]
module.subnets.aws_eip.default[2]: Still creating... [10s elapsed]
module.vpc.aws_vpc.default: Still creating... [10s elapsed]
module.subnets.aws_eip.default[0]: Creation complete after 11s [id=eipalloc-0e9053c5f86b33c8d]
module.subnets.aws_eip.default[2]: Creation complete after 12s [id=eipalloc-0521d881079390336]
module.rds_cluster.aws_rds_cluster_parameter_group.default[0]: Creation complete after 17s [id=iac-dev-rds]
module.rds_cluster.aws_db_parameter_group.default[0]: Creation complete after 17s [id=iac-dev-rds]
module.vpc.aws_vpc.default: Creation complete after 19s [id=vpc-08d226f74ecf87bde]
module.subnets.data.aws_vpc.default: Refreshing state...
module.vpc.aws_internet_gateway.default: Creating...
module.vpc.aws_default_security_group.default: Creating...
aws_security_group.iac-dev-rds-sg: Creating...
aws_security_group.iac-dev-ec2-sg: Creating...
module.subnets.aws_route_table.public[0]: Creating...
module.subnets.aws_route_table.private[2]: Creating...
module.subnets.aws_route_table.private[0]: Creating...
module.subnets.aws_subnet.public[1]: Creating...
module.subnets.aws_subnet.private[0]: Creating...
module.subnets.aws_subnet.private[1]: Creating...
aws_security_group.iac-dev-ec2-sg: Still creating... [10s elapsed]
module.vpc.aws_default_security_group.default: Still creating... [10s elapsed]
aws_security_group.iac-dev-rds-sg: Still creating... [10s elapsed]
module.vpc.aws_internet_gateway.default: Still creating... [10s elapsed]
module.vpc.aws_default_security_group.default: Creation complete after 12s [id=sg-0f265aa1b3d151ab5]
module.subnets.aws_subnet.public[2]: Creating...
aws_security_group.iac-dev-ec2-sg: Creation complete after 12s [id=sg-0011d0ea96268d7e4]
module.subnets.aws_subnet.private[2]: Creating...
module.subnets.aws_subnet.private[0]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[1]: Still creating... [10s elapsed]
module.subnets.aws_subnet.public[1]: Still creating... [10s elapsed]
module.subnets.aws_route_table.public[0]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[0]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[1]: Creation complete after 11s [id=subnet-0700366c1904a23fa]
module.subnets.aws_route_table.private[1]: Creating...
module.subnets.aws_subnet.private[0]: Creation complete after 11s [id=subnet-095de7b7bd92cc361]
module.subnets.aws_subnet.public[0]: Creating...
module.subnets.aws_route_table.private[2]: Creation complete after 11s [id=rtb-06bb7abf998a322f6]
aws_security_group_rule.ingress[2]: Creating...
module.subnets.aws_route_table.private[0]: Creation complete after 11s [id=rtb-0d2be95f008699d01]
aws_security_group.iac-dev-rds-sg: Creation complete after 17s [id=sg-0815015a00ae40db6]
aws_security_group_rule.egress[0]: Creating...
aws_security_group_rule.ingress[3]: Creating...
module.vpc.aws_internet_gateway.default: Creation complete after 17s [id=igw-013830692a5db59ff]
aws_security_group_rule.ingress[0]: Creating...
module.subnets.aws_route_table.public[0]: Creation complete after 12s [id=rtb-01d9e1c667bc4d5b3]
aws_security_group_rule.ingress[1]: Creating...
module.subnets.aws_subnet.public[1]: Creation complete after 12s [id=subnet-0edd8546b7d4fdd40]
aws_security_group_rule.rds_ingress_dynamic[0]: Creating...
module.subnets.aws_subnet.public[2]: Still creating... [10s elapsed]
module.subnets.aws_subnet.private[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table.private[1]: Still creating... [10s elapsed]
module.subnets.aws_subnet.public[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[2]: Still creating... [10s elapsed]
aws_security_group_rule.egress[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[3]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[1]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress_dynamic[0]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[2]: Creation complete after 11s [id=sgrule-3221212493]
aws_security_group_rule.rds_ingress[0]: Creating...
module.subnets.aws_subnet.public[2]: Creation complete after 16s [id=subnet-0f939733caf1f2460]
aws_security_group_rule.rds_egress[0]: Creating...
module.subnets.aws_subnet.private[2]: Creation complete after 16s [id=subnet-019a4ee2c860b8c5f]
aws_security_group_rule.rds_ingress[1]: Creating...
module.subnets.aws_subnet.public[0]: Creation complete after 16s [id=subnet-0645634732d740546]
module.subnets.aws_route_table.private[1]: Creation complete after 16s [id=rtb-04f89428e67b0ee3b]
module.subnets.aws_network_acl.private[0]: Creating...
module.rds_cluster.aws_security_group.default[0]: Creating...
aws_security_group_rule.rds_ingress_dynamic[0]: Creation complete after 15s [id=sgrule-3010855469]
module.subnets.aws_route_table_association.public[2]: Creating...
aws_security_group_rule.egress[0]: Creation complete after 17s [id=sgrule-2232867475]
module.subnets.aws_nat_gateway.default[1]: Creating...
aws_security_group_rule.ingress[3]: Still creating... [20s elapsed]
aws_security_group_rule.ingress[0]: Still creating... [20s elapsed]
aws_security_group_rule.ingress[1]: Still creating... [20s elapsed]
aws_security_group_rule.rds_ingress[0]: Still creating... [10s elapsed]
aws_security_group_rule.rds_egress[0]: Still creating... [10s elapsed]
aws_security_group_rule.rds_ingress[1]: Still creating... [10s elapsed]
module.subnets.aws_route_table_association.public[2]: Creation complete after 6s [id=rtbassoc-0acac9831f27aed56]
module.subnets.aws_route_table_association.public[1]: Creating...
module.subnets.aws_network_acl.private[0]: Still creating... [10s elapsed]
module.rds_cluster.aws_security_group.default[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [10s elapsed]
aws_security_group_rule.ingress[3]: Creation complete after 27s [id=sgrule-544208436]
module.subnets.aws_nat_gateway.default[0]: Creating...
module.subnets.aws_route_table_association.public[1]: Creation complete after 5s [id=rtbassoc-066b0e4ea65dbb9df]
module.subnets.aws_route_table_association.public[0]: Creating...
aws_security_group_rule.rds_ingress[0]: Creation complete after 16s [id=sgrule-1961041413]
module.subnets.aws_network_acl.public[0]: Creating...
module.subnets.aws_route_table_association.public[0]: Creation complete after 1s [id=rtbassoc-046453d42d4188e95]
module.subnets.aws_nat_gateway.default[2]: Creating...
aws_security_group_rule.ingress[0]: Still creating... [30s elapsed]
aws_security_group_rule.ingress[1]: Still creating... [30s elapsed]
aws_security_group_rule.rds_egress[0]: Still creating... [20s elapsed]
aws_security_group_rule.rds_ingress[1]: Still creating... [20s elapsed]
aws_security_group_rule.rds_egress[0]: Creation complete after 22s [id=sgrule-1043594018]
module.subnets.aws_route_table_association.private[0]: Creating...
aws_security_group_rule.ingress[0]: Creation complete after 33s [id=sgrule-1333537011]
module.subnets.aws_route_table_association.private[2]: Creating...
module.subnets.aws_route_table_association.private[0]: Creation complete after 0s [id=rtbassoc-067ff17bad4cead21]
module.subnets.aws_route_table_association.private[1]: Creating...
module.subnets.aws_route_table_association.private[2]: Creation complete after 0s [id=rtbassoc-020b10e712ad25ebb]
aws_elb.iac-dev-asg-elb: Creating...
module.rds_cluster.aws_security_group.default[0]: Still creating... [20s elapsed]
module.subnets.aws_network_acl.private[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [10s elapsed]
module.subnets.aws_network_acl.public[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [10s elapsed]
module.subnets.aws_route_table_association.private[1]: Creation complete after 6s [id=rtbassoc-0b2b386e35e65dd27]
module.subnets.aws_route.public[0]: Creating...
module.rds_cluster.aws_security_group.default[0]: Creation complete after 23s [id=sg-00b98ce94f831fa4b]
module.rds_cluster.aws_db_subnet_group.default[0]: Creating...
aws_elb.iac-dev-asg-elb: Creation complete after 6s [id=iac-dev-asg-elb]
aws_security_group_rule.ingress[1]: Creation complete after 38s [id=sgrule-4193678662]
aws_security_group_rule.rds_ingress[1]: Creation complete after 28s [id=sgrule-2984691327]
module.subnets.aws_route.public[0]: Creation complete after 0s [id=r-rtb-01d9e1c667bc4d5b31080289494]
module.subnets.aws_network_acl.private[0]: Creation complete after 24s [id=acl-0c0fbb4f6948e007f]
module.rds_cluster.aws_db_subnet_group.default[0]: Creation complete after 1s [id=iac-dev-rds]
module.rds_cluster.aws_rds_cluster.default[0]: Creating...
module.subnets.aws_network_acl.public[0]: Creation complete after 19s [id=acl-0b55b97baf7dc529e]
module.subnets.aws_nat_gateway.default[1]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [20s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [30s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [40s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m0s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [50s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m10s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m0s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m0s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Still creating... [50s elapsed]
module.rds_cluster.aws_rds_cluster.default[0]: Creation complete after 53s [id=iac-dev-rds]
data.template_file.user_data: Refreshing state...
data.template_file.rds: Refreshing state...
module.rds_cluster.aws_rds_cluster_instance.default[0]: Creating...
module.iac-dev-ecp.aws_launch_template.default[0]: Creating...
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m20s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m10s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m10s elapsed]
module.iac-dev-ecp.aws_launch_template.default[0]: Creation complete after 6s [id=lt-0d2cbcb24c185bc4f]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Creating...
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [10s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m30s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m20s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m20s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [10s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [20s elapsed]
module.subnets.aws_nat_gateway.default[1]: Still creating... [1m40s elapsed]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m30s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m30s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [30s elapsed]
module.subnets.aws_nat_gateway.default[1]: Creation complete after 1m48s [id=nat-09204f68b5c35e0e4]
module.subnets.aws_nat_gateway.default[0]: Still creating... [1m40s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m40s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [40s elapsed]
module.subnets.aws_nat_gateway.default[0]: Creation complete after 1m49s [id=nat-0e1e552489ef6544e]
module.subnets.aws_nat_gateway.default[2]: Still creating... [1m50s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [40s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[2]: Still creating... [2m0s elapsed]
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Still creating... [50s elapsed]
module.subnets.aws_nat_gateway.default[2]: Creation complete after 2m3s [id=nat-08e54929b93cd2d6f]
module.subnets.aws_route.default[0]: Creating...
module.subnets.aws_route.default[1]: Creating...
module.subnets.aws_route.default[2]: Creating...
module.iac-dev-ecp.aws_autoscaling_group.default[0]: Creation complete after 53s [id=iac-dev-ec2-asg-20200206193555597000000003]
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Creating...
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Creating...
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m0s elapsed]
module.iac-dev-ecp.aws_autoscaling_policy.scale_up[0]: Creation complete after 1s [id=iac-dev-ec2-asg-scale-up]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Creating...
module.iac-dev-ecp.aws_autoscaling_policy.scale_down[0]: Creation complete after 1s [id=iac-dev-ec2-asg-scale-down]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Creating...
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_high[0]: Creation complete after 1s [id=iac-dev-ec2-asg-cpu-utilization-high]
module.iac-dev-ecp.aws_cloudwatch_metric_alarm.cpu_low[0]: Creation complete after 1s [id=iac-dev-ec2-asg-cpu-utilization-low]
module.subnets.aws_route.default[1]: Creation complete after 6s [id=r-rtb-04f89428e67b0ee3b1080289494]
module.subnets.aws_route.default[2]: Still creating... [10s elapsed]
module.subnets.aws_route.default[0]: Still creating... [10s elapsed]
module.subnets.aws_route.default[0]: Creation complete after 11s [id=r-rtb-0d2be95f008699d011080289494]
module.subnets.aws_route.default[2]: Creation complete after 11s [id=r-rtb-06bb7abf998a322f61080289494]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [1m10s elapsed]
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
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [6m20s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Still creating... [6m30s elapsed]
module.rds_cluster.aws_rds_cluster_instance.default[0]: Creation complete after 6m33s [id=iac-dev-rds-1]

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

alb_dns_name = iac-dev-asg-elb-1149699757.us-west-2.elb.amazonaws.com
arn = arn:aws:rds:us-west-2:684231869031:cluster:iac-dev-rds
autoscaling_group_arn = arn:aws:autoscaling:us-west-2:684231869031:autoScalingGroup:8a5d6fc0-11f0-428f-8ef5-ae000b08871c:autoScalingGroupName/iac-dev-ec2-asg-20200206193555597000000003
autoscaling_group_default_cooldown = 300
autoscaling_group_desired_capacity = 1
autoscaling_group_health_check_grace_period = 300
autoscaling_group_health_check_type = EC2
autoscaling_group_id = iac-dev-ec2-asg-20200206193555597000000003
autoscaling_group_max_size = 2
autoscaling_group_min_size = 1
autoscaling_group_name = iac-dev-ec2-asg-20200206193555597000000003
cluster_identifier = iac-dev-rds
cluster_resource_id = cluster-CHEEZR3224JY7QPTYIUNDFBDYA
database_name = iac_db
dbi_resource_ids = [
  "db-76TLB4D3QU4IZZTZQ23DORGCP4",
]
endpoint = iac-dev-rds.cluster-cljs7deqffpe.us-west-2.rds.amazonaws.com
launch_template_arn = arn:aws:ec2:us-west-2::launch-template/lt-0d2cbcb24c185bc4f
launch_template_id = lt-0d2cbcb24c185bc4f
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
reader_endpoint = iac-dev-rds.cluster-ro-cljs7deqffpe.us-west-2.rds.amazonaws.com
replicas_host =
vpc_cidr = 10.0.0.0/16
```

### Check Endpoint: 
Once `terraform apply` is `successful`, you will see the `elb_dns_name` configured as a part of output. you can hit `elb_dns_name` in your browser and should see the sample response from nginx container deployed or you can access `elb_dns_name` from CLI as well as given below.

```bash
while true; do curl -s -o /dev/null -w "%{http_code} => OK\n" iac-dev-asg-elb-1149699757.us-west-2.elb.amazonaws.com; done

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

> http://iac-dev-asg-elb-1149699757.us-west-2.elb.amazonaws.com

![WebApp](https://imgur.com/ZrwaHzO.png)


### Terraform State File ( Private API)
The state file format is a private API that changes with every release and is meant only for internal use within Terraform. You should never edit the Terraform state files by hand or write code that reads them directly.

```yaml 
$ terraform init -backend-config=backend.hcl

Initializing modules...

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```yaml
$ terraform plan -var-file=iac-cluster.tfvars -out=./plan/iac-cluster.plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_dynamodb_table.iac-cluster-locks will be created
  + resource "aws_dynamodb_table" "iac-cluster-locks" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "iac-cluster-tfstate-locks"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # aws_s3_bucket.iac-cluster-state will be created
  + resource "aws_s3_bucket" "iac-cluster-state" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "iac-cluster-tfstate"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + sse_algorithm = "AES256"
                }
            }
        }

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # module.iac-dev-ecp.aws_launch_template.default[0] will be updated in-place
  ~ resource "aws_launch_template" "default" {
        arn                                  = "arn:aws:ec2:us-west-2::launch-template/lt-0d2cbcb24c185bc4f"
        default_version                      = 1
        disable_api_termination              = false
        ebs_optimized                        = "false"
        id                                   = "lt-0d2cbcb24c185bc4f"
        image_id                             = "ami-0d1cd67c26f5fca19"
        instance_initiated_shutdown_behavior = "terminate"
        instance_type                        = "t2.micro"
        key_name                             = "iac-dev-iac-cluster"
      ~ latest_version                       = 1 -> (known after apply)
        name                                 = "iac-dev-ec2-asg-20200206193549778400000001"
        name_prefix                          = "iac-dev-ec2-asg-"
        security_group_names                 = []
        tags                                 = {
            "Name"      = "iac-dev-ec2"
            "Namespace" = "iac"
            "Owner"     = "Terraform"
            "Stage"     = "dev"
            "Tier"      = "1"
        }
        user_data                            = "IyEvdXNyL2Jpbi9lbnYgYmFzaAoKaWYgWyAiJCguIC9ldGMvb3MtcmVsZWFzZTsgZWNobyAkTkFNRSkiID0gIlVidW50dSIgXTsgdGhlbgogIGFwdC1nZXQgdXBkYXRlCiAgYXB0LWdldCAteSBpbnN0YWxsIGZpZ2xldAogIFNTSF9VU0VSPXVidW50dQplbHNlCiAgeXVtIGluc3RhbGwgZXBlbC1yZWxlYXNlIC15CiAgeXVtIGluc3RhbGwgZmlnbGV0IC15CiAgU1NIX1VTRVI9ZWMyLXVzZXIKZmkKIyBHZW5lcmF0ZSBzeXN0ZW0gYmFubmVyCmZpZ2xldCAiV2VsY29tZSB0byBDb250cm9sIFNlcnZlciIgPiAvZXRjL21vdGQKCgojIwojIyBTZXR1cCBTU0ggQ29uZmlnCiMjCmNhdCA8PCJfX0VPRl9fIiA+IC9ob21lL1NTSF9VU0VSLy5zc2gvY29uZmlnCkhvc3QgKgogICAgU3RyaWN0SG9zdEtleUNoZWNraW5nIG5vCl9fRU9GX18KY2htb2QgNjAwIC9ob21lLyRTU0hfVVNFUi8uc3NoL2NvbmZpZwpjaG93biAkU1NIX1VTRVI6JFNTSF9VU0VSIC9ob21lL1NTSF9VU0VSLy5zc2gvY29uZmlnCgojIwojIyBTZXR1cCBIVE1MCiMjCnN1ZG8gbWtkaXIgLXAgL29wdC9pYWMKc3VkbyBjaG93biAtUiBhZG1pbi5hZG1pbiAvb3B0L2lhYwpjYXQgPDwiX19FT0ZfXyIgPiAvb3B0L2lhYy9pbmRleC5odG1sCjxoMT5EYXRhYmFzZSBJbmZvOiA8L2gxPgo8cD48c3Ryb25nPlBvc3RncmVTUUwgRW5kb2ludDo8L3N0cm9uZz4gaWFjLWRldi1yZHMuY2x1c3Rlci1jbGpzN2RlcWZmcGUudXMtd2VzdC0yLnJkcy5hbWF6b25hd3MuY29tPC9wPgo8cD48c3Ryb25nPlBvc3RncmVTUUwgSW5zdGFuY2U6PC9zdHJvbmc+IGlhY19kYjwvcD4KCjxmb290ZXI+CiAgPHA+PHN0cm9uZz5Qb3N0ZWQgYnk6PC9zdHJvbmc+IEplZmZyeSBNaWxhbjwvcD4KICA8cD48c3Ryb25nPkNvbnRhY3QgaW5mb3JtYXRpb246PC9zdHJvbmc+IDxhIGhyZWY9Im1haWx0bzpqZWZmcnkubWlsYW5AZ21haWwuY29tIj5qdG1pbGFuQGdtYWlsLmNvbTwvYT4uPC9wPgo8L2Zvb3Rlcj4KPHA+PHN0cm9uZz5Ob3RlOjwvc3Ryb25nPiBUaGUgZW52aXJvbm1lbnQgc3BlY2lmaWVkIGlzIGEgbmFpdmUgcmVwcmVzZW50YXRpb24gb2YgYSB3ZWIgYXBwbGljYXRpb24gd2l0aCBhIGRhdGFiYXNlIGJhY2tlbmQuPC9wPgpfX0VPRl9fCgojIS9iaW4vYmFzaAphcHQtZ2V0IHVwZGF0ZQphcHQgLXkgaW5zdGFsbCBuZ2lueAphcHQgLXkgaW5zdGFsbCBkb2NrZXIuaW8KdWZ3IGFsbG93ICdOZ2lueCBIVFRQJwpzeXN0ZW1jdGwgc3RhcnQgZG9ja2VyCnN5c3RlbWN0bCBlbmFibGUgZG9ja2VyCmRvY2tlciBydW4gLS1uYW1lIGlhYy1uZ2lueCAtLXJlc3RhcnQ9dW5sZXNzLXN0b3BwZWQgLXYgL29wdC9pYWM6L3Vzci9zaGFyZS9uZ2lueC9odG1sOnJvIC1kIC1wIDgwODA6ODAgbmdpbngKCg=="
        vpc_security_group_ids               = []

      + iam_instance_profile {}

        monitoring {
            enabled = true
        }

        network_interfaces {
            associate_public_ip_address = "true"
            delete_on_termination       = true
            description                 = "iac-dev-ec2-asg"
            device_index                = 0
            ipv4_address_count          = 0
            ipv4_addresses              = []
            ipv6_address_count          = 0
            ipv6_addresses              = []
            security_groups             = [
                "sg-0011d0ea96268d7e4",
            ]
        }

        tag_specifications {
            resource_type = "volume"
            tags          = {
                "Name"      = "iac-dev-ec2"
                "Namespace" = "iac"
                "Owner"     = "Terraform"
                "Stage"     = "dev"
                "Tier"      = "1"
            }
        }
        tag_specifications {
            resource_type = "instance"
            tags          = {
                "Name"      = "iac-dev-ec2"
                "Namespace" = "iac"
                "Owner"     = "Terraform"
                "Stage"     = "dev"
                "Tier"      = "1"
            }
        }
    }

Plan: 2 to add, 1 to change, 0 to destroy.



------------------------------------------------------------------------

This plan was saved to: ./plan/iac-cluster.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "./plan/iac-cluster.plan"
```
```
$ terraform apply "./plan/iac-cluster.plan"
aws_dynamodb_table.iac-cluster-locks: Creating...
aws_s3_bucket.iac-cluster-state: Creating...
module.iac-dev-ecp.aws_launch_template.default[0]: Modifying... [id=lt-0d2cbcb24c185bc4f]
module.iac-dev-ecp.aws_launch_template.default[0]: Modifications complete after 7s [id=lt-0d2cbcb24c185bc4f]
aws_s3_bucket.iac-cluster-state: Still creating... [10s elapsed]
aws_dynamodb_table.iac-cluster-locks: Still creating... [10s elapsed]
aws_dynamodb_table.iac-cluster-locks: Still creating... [20s elapsed]
aws_s3_bucket.iac-cluster-state: Still creating... [20s elapsed]
aws_dynamodb_table.iac-cluster-locks: Creation complete after 22s [id=iac-cluster-tfstate-locks]
aws_s3_bucket.iac-cluster-state: Still creating... [30s elapsed]
aws_s3_bucket.iac-cluster-state: Creation complete after 40s [id=iac-cluster-tfstate]

Apply complete! Resources: 2 added, 1 changed, 0 destroyed.
```

### Destroy Infrastructure(clean-up)

This is not yet done.

```
$ terraform plan -destroy -var-file=iac-cluster.tfvars -out=./destroy/iac-cluster.destroy
```

```
$ terraform apply "./destroy/iac-cluster.destroy"
```

### END - Thank you.