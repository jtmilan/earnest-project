resource "aws_security_group" "iac-dev-ec2-sg" {
  name              = "iac-dev-ec2-sg"
  description       = "security group for ec2 instance"
  vpc_id            = module.vpc.vpc_id   
  
  tags = {
      Name  = "iac-dev-ec2-sg"
      Owner  = "Terraform"
  }

}

resource "aws_security_group_rule" "egress" {
  count             = var.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iac-dev-ec2-sg.id
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create_security_group ? length(compact(var.allowed_ports)) : 0
  type              = "ingress"
  from_port         = var.allowed_ports[count.index]
  to_port           = var.allowed_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iac-dev-ec2-sg.id
}

#RDS Security Group
resource "aws_security_group" "iac-dev-rds-sg" {
  name              = "iac-dev-rds-sg"
  description       = "security group for rds instances"
  vpc_id            = module.vpc.vpc_id   

  tags = {
      Name  = "iac-dev-rds-sg"
      Owner  = "Terraform"
  }
}

resource "aws_security_group_rule" "rds_egress" {
  count             = var.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iac-dev-rds-sg.id
}

resource "aws_security_group_rule" "rds_ingress" {
  count             = var.create_security_group ? length(compact(var.rds_allowed_ports)) : 0
  type              = "ingress"
  from_port         = var.rds_allowed_ports[count.index]
  to_port           = var.rds_allowed_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iac-dev-rds-sg.id
}

resource "aws_security_group_rule" "rds_ingress_dynamic" {
  count             = var.create_security_group ? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iac-dev-rds-sg.id
}

