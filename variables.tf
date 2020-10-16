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

variable "additional_tag_map" {
  type        = map(string)
  description = "Map of additional tags to apply to every taggable resource. If you don't want any use an empty map - '{}'"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use. See the Kubernetes Version dropdown in the Add Cluster - Custom view in Rancher for the available options"
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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy to"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy into"
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

variable "protect_from_scale_in" {
  type        = bool
  description = "If true, AutoScaling Group protect_from_scale_in will be set to true. This should be true in production, but it will prevent you from destroying the stack since the ASG will get stuck waiting for instances to be manually terminated"
}

variable "region" {
  type        = string
  description = "Region you are deploying to"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address to use for LetsEncrypt certs"
}

//variable "instance_type" {
//  type        = string
//  description = "Instance type to use for the cluster nodes"
//}
//
//variable "node_group_1_subnet_id" {
//  type        = string
//  description = "Subnet to deploy node group 1 to"
//}
//
//variable "node_group_2_subnet_id" {
//  type        = string
//  description = "Subnet to deploy node group 2 to"
//}
//
//variable "node_group_3_subnet_id" {
//  type        = string
//  description = "Subnet to deploy node group 3 to"
//}
//
//variable "hosted_zone_id" {
//  type        = string
//  description = "ID of Route53 hosted zone to create records in"
//}
//
//variable "hosted_zone_domain_name" {
//  type        = string
//  description = "Domain name of the hosted zone to create records in"
//}
//
//variable "subdomain_rancher" {
//  type        = string
//  description = "Rancher's endpoint will be '{subdomain_rancher}.{hosted_zone_domain_name}'. {subdomain_rancher} can be multi-layered e.g. 'rancher.foo.bar'"
//}
//
//variable "rancher_letsencrypt_email" {
//  type        = string
//  description = "Email address to use for Rancher's LetsEncrypt certificate"
//}
//
//variable "rancher_letsencrypt_environment" {
//  type        = string
//  description = "LetsEncrypt environment to use - Valid options: 'staging', 'production'"
//}
