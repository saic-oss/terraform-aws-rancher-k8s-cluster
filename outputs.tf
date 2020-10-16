output "ssh_public_key" {
  description = "Cluster nodes' public SSH key"
  value       = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key" {
  description = "Cluster nodes' private SSH key"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "cluster_kubeconfig" {
  description = "KUBECONFIG yaml file contents to connect to the cluster. This should only be used by bots. Humans should use the KUBECONFIG that Rancher gives them."
  value       = rancher2_cluster.default.kube_config
  sensitive   = true
}

output "elb_dns_name" {
  description = "DNS Name of the ELB that was created"
  value       = aws_elb.ingress.dns_name
}

output "elb_zone_id" {
  description = "Zone ID of the ELB that was created"
  value       = aws_elb.ingress.zone_id
}
