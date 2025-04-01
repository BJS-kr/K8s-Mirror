resource "kubernetes_horizontal_pod_autoscaler" "account_service_hpa" {
  metadata {
    name = "account-service-hpa"
  }
  spec {
    max_replicas = var.service_max_replicas
    min_replicas = var.service_min_replicas 
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "account-service-depl"
    }
    target_cpu_utilization_percentage = var.service_target_cpu_utilization_percentage
  }
}