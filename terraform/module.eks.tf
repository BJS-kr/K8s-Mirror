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
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}