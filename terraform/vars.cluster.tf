variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

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
