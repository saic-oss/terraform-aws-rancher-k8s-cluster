variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  type        = string
  description = "Solution name"
}

variable "repo" {
  type        = string
  description = "Repo URL that is responsible for this resource"
}

variable "owner" {
  type        = string
  description = "Email address of owner"
}

variable "description" {
  type        = string
  description = "Short description of what/why this product exists"
}

variable "additional_tag_map" {
  type        = map(string)
  description = "Map of additional tags to apply to every taggable resource. If you don't want any use an empty map - '{}'"
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "controlplane_instance_type" {
  type        = string
  description = "Instance type of the control plane nodes"
}

variable "worker_instance_type" {
  type        = string
  description = "Instance type of the worker nodes"
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "If true, the launched EC2 instances will have detailed monitoring enabled"
}

variable "node_volume_size" {
  type        = string
  description = "Volume size of worker node disk in GB"
}

variable "worker_max_size" {
  type        = number
  description = "Maximum number of workers"
}
variable "worker_min_size" {
  type        = number
  description = "Minimum number of workers"
}
variable "worker_desired_capacity" {
  type        = number
  description = "Desired number of workers"
}

variable "master_cluster_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the master cluster. Must be supported by the version of the RKE provider you are using. See https://github.com/rancher/terraform-provider-rke/releases"
}

variable "worker_cluster_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the worker cluster"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of Route53 hosted zone to create records in"
}

variable "hosted_zone_domain_name" {
  type        = string
  description = "Domain name of the hosted zone to create records in"
}

variable "subdomain_rancher_prefix" {
  type        = string
  description = "Rancher's endpoint will be '{subdomain_rancher}.{hosted_zone}'. {subdomain_rancher} can be multi-layered e.g. 'rancher.foo.bar'. A random pet name will be added on for deconfliction"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs to deploy to"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address to use for LetsEncrypt certificate"
}

variable "rancher_letsencrypt_environment" {
  type        = string
  description = "LetsEncrypt environment to use - Valid options: 'staging', 'production'"
}

variable "protect_from_scale_in" {
  type        = bool
  description = "If true, AutoScaling Group protect_from_scale_in will be set to true. This should be true in production, but it will prevent you from destroying the stack since the ASG will get stuck waiting for instances to be manually terminated"
}
