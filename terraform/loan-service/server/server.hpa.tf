resource "kubernetes_horizontal_pod_autoscaler" "loan_service_hpa" {
  metadata {
    name = "loan-service-hpa"
  }
  spec {
    max_replicas = var.service_max_replicas
    min_replicas = var.service_min_replicas 
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "loan-service-depl"
    }
    target_cpu_utilization_percentage = var.service_target_cpu_utilization_percentage
  }
}