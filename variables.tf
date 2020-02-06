variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloud`)"
  type        = string
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
}

variable "name" {
  type        = string
  description = "Application or solution name"
}

variable "region" {
  type = string
}

variable "ami" {
  type = string
  description = "AMI ID image"
}

variable "instance" {
  type = string
  description = "name of instance"
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr" {
  type = string
}

variable "ssh_name" {
  type        = string
  description = "SSH key pair name"
}

variable "ssh_key_pair" {
  type        = string
  description = "SSH key pair to be provisioned on the instance"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "generate_ssh_key" {
  type        = bool
  description = "If set to `true`, new SSH key pair will be created"
}

variable "chmod_command" {
  type        = string
  default     = "chmod 600 %v"
  description = "Template of the command executed on the private key file"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
}

variable "security_groups" {
  description = "List of Security Group IDs allowed to connect to the instance"
  type        = list(string)
  default     = []
}

#Welcome Messages
variable "welcome_message" {
  type        = string
  default     = ""
  description = "Welcome to Control Server"
}

variable "allowed_ports" {
  type        = list(number)
  description = "List of allowed ingress ports"
  default     = []
}

variable "create_security_group" {
  type        = bool
  description = "Create default Security Group with only Egress traffic allowed"
  default     = true
}

variable "user_data" {
  type        = string
  description = "Instance user data. Do not pass gzip-compressed data via this argument"
  default     = ""
}

#EC2
variable "ami_owner" {
  type        = string
  description = "Owner of the given AMI (ignored if `ami` unset)"
  default     = ""
}

#RDS
variable "rds_name" {
  description = "RDS"
  type        = string
}

variable "rds_allowed_ports" {
  type        = list(number)
  description = "RDS Lists of allowed ingress ports"
  default     = []
}

variable "instance_type" {
  type        = string
  description = "Instance type to use"
}

variable "cluster_size" {
  type        = number
  description = "Number of DB instances to create in the cluster"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "admin_user" {
  type        = string
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "admin_password" {
  type        = string
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user"
}

variable "cluster_family" {
  type        = string
  description = "The family of the DB cluster parameter group"
}

variable "engine" {
  type        = string
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "engine_mode" {
  type        = string
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

#ASG
variable "asg_name" {
  description = "Auto Scaling Group Name"
  type        = string
}

variable "health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
}

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the autoscale group"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  description = "CPU utilization high threshold"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  description = "CPU utilization low threshold"
}
