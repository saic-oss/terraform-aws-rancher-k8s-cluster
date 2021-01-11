provider "aws" {
  region = var.region
}

provider "random" {}

provider "tls" {}

provider "rke" {
  debug = true
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = local.rancher_endpoint
  insecure  = true #should be false in production!
  bootstrap = true
}

provider "rancher2" {
  alias     = "admin"
  api_url   = module.rke_rancher_master_cluster.rancher_endpoint
  insecure  = true #should be false in production!
  token_key = module.rke_rancher_master_cluster.rancher_admin_token
}

resource "random_pet" "default" {
  length    = 2
  prefix    = "example"
  separator = "-"
}

locals {
  subdomain_rancher_with_entropy = "${var.subdomain_rancher_prefix}.${random_pet.default.id}"
  rancher_endpoint               = "https://${local.subdomain_rancher_with_entropy}.${var.hosted_zone_domain_name}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.16.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.31.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
  depends_on = [
    module.vpc
  ]
}

module "rke_rancher_master_cluster" {
  source                          = "git::https://github.com/saic-oss/terraform-aws-rke-rancher-master-cluster.git?ref=tags/0.4.1"
  additional_tag_map              = {}
  description                     = var.description
  instance_type                   = var.controlplane_instance_type
  kubernetes_version              = var.master_cluster_kubernetes_version
  name                            = var.name
  namespace                       = var.namespace
  node_group_1_subnet_id          = module.subnets.public_subnet_ids[0]
  node_group_2_subnet_id          = module.subnets.public_subnet_ids[1]
  node_group_3_subnet_id          = module.subnets.public_subnet_ids[2]
  node_volume_size                = var.node_volume_size
  owner                           = var.owner
  repo                            = var.repo
  stage                           = var.stage
  vpc_id                          = module.vpc.vpc_id
  hosted_zone_id                  = var.hosted_zone_id
  hosted_zone_domain_name         = var.hosted_zone_domain_name
  subdomain_rancher               = local.subdomain_rancher_with_entropy
  rancher_letsencrypt_email       = var.letsencrypt_email
  rancher_letsencrypt_environment = var.rancher_letsencrypt_environment
  depends_on = [
    module.vpc,
    module.subnets
  ]
  providers = {
    aws                = aws
    random             = random
    tls                = tls
    rke                = rke
    rancher2.bootstrap = rancher2.bootstrap
  }
}

module "rancher-k8s-cluster" {
  //source                   = "git::https://path/to/repo.git?ref=tags/x.y.z"
  source                     = "../.."
  additional_tag_map         = {}
  description                = var.description
  kubernetes_version         = var.worker_cluster_kubernetes_version
  name                       = "${var.name}-workload"
  namespace                  = var.namespace
  owner                      = var.owner
  repo                       = var.repo
  stage                      = var.stage
  region                     = var.region
  letsencrypt_email          = var.letsencrypt_email
  controlplane_instance_type = var.controlplane_instance_type
  enable_detailed_monitoring = var.enable_detailed_monitoring
  node_volume_size           = var.node_volume_size
  subnet_ids                 = module.subnets.public_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  worker_desired_capacity    = var.worker_desired_capacity
  worker_instance_type       = var.worker_instance_type
  worker_max_size            = var.worker_max_size
  worker_min_size            = var.worker_min_size
  protect_from_scale_in      = var.protect_from_scale_in
  depends_on = [
    module.rke_rancher_master_cluster
  ]
  providers = {
    aws            = aws
    random         = random
    tls            = tls
    rancher2.admin = rancher2.admin
  }
}
