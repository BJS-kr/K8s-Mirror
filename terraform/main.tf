terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}

provider "kubernetes" {
  host                   =   module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  create_node_security_group = false

  cluster_addons =  {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    metrics-server = {
      most_recent = true
    }
  }
  eks_managed_node_groups = {
    private = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

      subnet_ids = module.vpc.private_subnets

      labels = {
        "network" =  "private"
      }
      iam_role_additional_policies = {
        AmazonEKS_EBS_CSI_DriverRole  = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }

    # public = {
    #   min_size     = var.node_group_min_size
    #   max_size     = var.node_group_max_size
    #   desired_size = var.node_group_desired_size

    #   instance_types = var.node_group_instance_types
    #   capacity_type  = var.node_group_capacity_type

    #   subnet_ids = module.vpc.public_subnets

    #   labels = {
    #     "network" = "public"
    #   }
    # }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
} 
