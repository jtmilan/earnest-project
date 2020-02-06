### Creating ELB
resource "aws_elb" "iac-dev-asg-elb" { 
  name               = "iac-dev-asg-elb"
  security_groups    = [aws_security_group.iac-dev-ec2-sg.id]
  subnets            = module.subnets.public_subnet_ids 
  // availability_zones = var.availability_zones

  listener {
    lb_port = 80
    lb_protocol = "tcp"
    instance_port = 8080
    instance_protocol = "tcp"
  }

# This can be used if we are planning to have https on domain.
#  listener {
#    instance_port      = 8080
#    instance_protocol  = "http"
#    lb_port            = 443
#    lb_protocol        = "https"
#    ssl_certificate_id = "arn:aws:iam::<ACCT-ID>:server-certificate/crtName"
#  }

  idle_timeout	      = 400
  connection_draining = true
  connection_draining_timeout = 400
}
