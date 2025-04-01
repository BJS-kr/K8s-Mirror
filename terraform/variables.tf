# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  type        = bool
}

# Node Group Configuration
variable "node_group_instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
}

variable "node_group_capacity_type" {
  description = "Capacity type for the node group"
  type        = string
}

variable "account_db_storage_size" {
  description = "Storage size for account service database"
  type        = string
}

variable "loan_db_storage_size" {
  description = "Storage size for loan service database"
  type        = string
}

variable "account_service_replicas" {
  description = "Number of replicas for account service"
  type        = number
}

variable "loan_service_replicas" {
  description = "Number of replicas for loan service"
  type        = number
}

variable "gateway_hostname" {
  description = "Hostname for the API gateway"
  type        = string
}

variable "account_db_user" {
  description = "Database user for account service"
  type        = string
}

variable "account_db_password" {
  description = "Database password for account service"
  type        = string
  sensitive   = true
}

variable "account_db_host" {
  description = "Database host for account service"
  type        = string
  sensitive = true
}

variable "account_db_name" {
  description = "Database name for account service"
  type        = string
  sensitive = true
}

variable "account_db_port" {
  description = "Database port for account service"
  type        = string
  sensitive = true
}

variable "account_service_http_port" {
  description = "HTTP port for account service"
  type        = string
}

variable "loan_db_password" {
  description = "Database password for loan service"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "aws access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "aws secret key"
  type        = string
  sensitive   = true
}

variable "admin_user_arn" {
  description = "admin user arn"
  type        = string
}