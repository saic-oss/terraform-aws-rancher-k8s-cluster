resource "null_resource" "helmfile_deployments" {
  triggers = {
    uuid = uuid()
  }
  provisioner "local-exec" {
    command = "helmfile -f ${path.module}/helmfiles/helmfile.yaml apply"
    environment = {
      KUBECONFIG         = abspath(local_file.kubeconfig.filename)
      LETSENCRYPT_EMAIL  = var.letsencrypt_email
      EFS_FILE_SYSTEM_ID = aws_efs_file_system.default.id
      AWS_REGION         = var.region
    }
  }
  depends_on = [
    rancher2_cluster_sync.default,
    local_file.kubeconfig
  ]
}
