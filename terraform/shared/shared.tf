resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type = "gp3"
    encrypted = "false"
    fsType = "ext4"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy = "Retain"
  allowed_topologies {
    match_label_expressions {
      key = "topology.ebs.csi.aws.com/zone"
      values = var.vpc_azs
    }
  }
}

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"

  ingress_class_name = "nginx"
  namespace = "ingress-nginx"
  create_namespace = true
  atomic = true

  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    }
  ]
}
