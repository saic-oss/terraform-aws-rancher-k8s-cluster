output "master_ssh_public_key" {
  description = "Public SSH key for master cluster nodes"
  value       = module.rke_rancher_master_cluster.ssh_public_key
}

output "master_ssh_private_key" {
  description = "Private SSH key for master cluster nodes"
  value       = module.rke_rancher_master_cluster.ssh_private_key
  sensitive   = true
}

output "master_cluster_kubeconfig" {
  description = "KUBECONFIG yaml file contents to connect to the cluster. DO NOT USE unless you have no other options. Users should use the KUBECONFIG that Rancher provides to them rather than this."
  value       = module.rke_rancher_master_cluster.cluster_kubeconfig
  sensitive   = true
}

output "rancher_endpoint" {
  description = "Endpoint of Rancher Server"
  value       = module.rke_rancher_master_cluster.rancher_endpoint
}

output "rancher_admin_password" {
  description = "Password for Rancher 'admin' user"
  value       = module.rke_rancher_master_cluster.rancher_admin_password
  sensitive   = true
}

output "worker_ssh_public_key" {
  description = "Public SSH key for worker cluster nodes"
  value       = module.rancher-k8s-cluster.ssh_public_key
}

output "worker_ssh_private_key" {
  description = "Private SSH key for the worker cluster nodes"
  value       = module.rancher-k8s-cluster.ssh_private_key
  sensitive   = true
}
