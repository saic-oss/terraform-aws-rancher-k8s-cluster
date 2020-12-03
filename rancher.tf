resource "rancher2_cluster" "default" {
  provider    = rancher2.admin
  name        = module.label.id
  description = "Workload cluster created by Terraform"
  rke_config {
    network {
      plugin = "canal"
    }
    kubernetes_version = var.kubernetes_version
  }
}

resource "rancher2_cluster_sync" "default" {
  provider        = rancher2.admin
  cluster_id      = rancher2_cluster.default.id
  state_confirm   = 36
  wait_monitoring = false
  timeouts {
    create = "60m"
  }
  depends_on = [
    aws_autoscaling_group.worker,
    aws_autoscaling_group.controlplane,
    aws_autoscaling_attachment.worker
  ]
}

resource "local_file" "kubeconfig" {
  filename        = "${path.module}/tmp/kubeconfig_${module.label.id}.yaml"
  content         = rancher2_cluster_sync.default.kube_config
  file_permission = "0644"
  depends_on = [
    rancher2_cluster_sync.default
  ]
}
