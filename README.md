# terraform-aws-rancher-k8s-cluster

Terraform module that uses the Rancher2 Terraform Provider and AWS Provider to create a new Kubernetes cluster that is managed by Rancher. Requires existing Rancher Server connection.

## Introduction

### Purpose

The purpose of this module is to give an easy to create a new "worker" Kubernetes cluster that is managed by Rancher. It is intended to be a "turn-key" module, so it includes (almost) everything needed to have the cluster up and running, including the AWS compute infrastructure, Kubernetes cluster, load balancer, Route53 DNS entry, and the registration of the cluster with Rancher.

### High-level design

#### Resources provisioned

- [x] A Kubernetes cluster from existing nodes (cluster type "custom") using the Terraform Rancher2 provider
- [x] An AutoScaling Group that will be used for the Kubernetes control plane nodes
- [x] An AutoScaling Group that will be used for the Kubernetes worker nodes
- [x] An EFS (Elastic File System)
- [x] A Classic Load Balancer (ELB) with listeners on port 80 and 443 that attach to the Worker ASG nodes (to be used with nginx-ingress)
  - Port 80 attaches to port 80 of the nodes
  - Port 443 attaches to port 443 of the nodes
  - The healthcheck target is `HTTP:80/healthz`
- [x] 3 Security Groups
  - The `nodes` security group is used by the EC2 instances and allows:
    - Any traffic inside its own security group
    - SSH traffic from anywhere
    - K8s API traffic from anywhere
    - Traffic on ports 80 and 443 from the `elb` security group (for nginx-ingress)
  - The `elb` security group is used by the load balancer(s) and allows:
    - Traffic on ports 80 and 443 from anywhere
  - The `nfs` security group allows NFS traffic in the stated subnets
- [x] An AWS Key Pair with a new TLS private key
- [x] A Route53 record that configures a dnsName to point at the ELB
- [x] Uses a `local-exec` that runs `helmfile apply` to install
  - CertManager
  - efs-provisioner
  - CertManager configuration

### Limitations

1. At the moment, this module cannot be deployed to private subnets. Deploying to private subnets can be added later if desired

## Usage

1. Terraform v0.13+ - Uses the new way to pull down 3rd party providers.
1. \*nix operating system - Windows not supported. If you need to use this on Windows you can run it from a Docker container.
1. Since this module uses a `local-exec`, the following tools also need to be installed on the machine using this module:
   1. [kubectl][kubectl]
   1. [helm][helm]
   1. [helmfile][helmfile]
   1. [helm-diff plugin][helm-diff]

### Instructions

#### Complete Example

See [examples/complete](examples/complete) for an example of how to use this module. For your convenience a Taskfile has been provided to be used with [go-task][go-task].

```sh
cd examples/complete
task init
task plan
task apply
task destroy
```

> There are a few parameters that are specific to your AWS account and your domain name you want to use that are not included in the example `terraform.tfvars`. You should create a `override.tfvars` file and add the missing parameters to that.

#### Provider config

This module uses provider aliases, so you have to explicitly pass in provider configurations. Here's a minimum example:

```hcl
provider "aws" {
  region = var.region
}

provider "random" {}

provider "tls" {}

provider "rke" {
  debug = true
}

provider "rancher2" {
  alias     = "admin"
  api_url   = module.rke_rancher_master_cluster.rancher_endpoint
  insecure  = true #should be false in production!
  token_key = module.rke_rancher_master_cluster.rancher_admin_token
}

module "rancher-k8s-cluster" {
  source                     = "git::https://path/to/repo.git?ref=tags/x.y.z"
  additional_tag_map         = {}
  kubernetes_version         = var.worker_cluster_kubernetes_version
  name                       = "${var.name}-workload"
  namespace                  = var.namespace
  stage                      = var.stage
  region                     = var.region
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
```

#### Getting the KUBECONFIG file

You SHOULD get the kubeconfig file from Rancher, but if you really need it without rancher, the contents are in the `cluster_kubeconfig` output.

## Contributing

Contributors to this module should make themselves familiar with this section

### Prerequisites

- Terraform v0.13+
- [pre-commit][pre-commit]
- Pre-commit hook dependencies
  - nodejs (for the prettier hook)
  - [tflint][tflint]
  - [terraform-docs][terraform-docs]
  - [tfsec][tfsec]
- Run `pre-commit install` in root dir of repo (installs the pre-commit hooks so they run automatically when you try to do a git commit)
- Run `terraform init` in root dir of repo so the pre-commit hooks can work

### Versioning

This module will use SemVer, and will stay on v0.X for the foreseeable future

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2.0.0 |
| local | >= 1.0.0 |
| null | >= 2.0.0 |
| rancher2 | >= 1.0.0 |
| random | >= 2.0.0 |
| template | >= 2.0.0 |
| tls | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0.0 |
| local | >= 1.0.0 |
| null | >= 2.0.0 |
| rancher2.admin | >= 1.0.0 |
| random | >= 2.0.0 |
| template | >= 2.0.0 |
| tls | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Map of additional tags to apply to every taggable resource. If you don't want any use an empty map - '{}' | `map(string)` | n/a | yes |
| controlplane\_instance\_type | Instance type of the control plane nodes | `string` | n/a | yes |
| description | Short description of what/why this product exists | `string` | n/a | yes |
| enable\_detailed\_monitoring | If true, the launched EC2 instances will have detailed monitoring enabled | `bool` | n/a | yes |
| kubernetes\_version | Kubernetes version to use. See the Kubernetes Version dropdown in the Add Cluster - Custom view in Rancher for the available options | `string` | n/a | yes |
| letsencrypt\_email | Email address to use for LetsEncrypt certs | `string` | n/a | yes |
| name | Solution name | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name or abbreviation | `string` | n/a | yes |
| node\_volume\_size | Volume size of worker node disk in GB | `string` | n/a | yes |
| owner | Email address of owner | `string` | n/a | yes |
| protect\_from\_scale\_in | If true, AutoScaling Group protect\_from\_scale\_in will be set to true. This should be true in production, but it will prevent you from destroying the stack since the ASG will get stuck waiting for instances to be manually terminated | `bool` | n/a | yes |
| region | Region you are deploying to | `string` | n/a | yes |
| repo | Repo URL that is responsible for this resource | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev' | `string` | n/a | yes |
| subnet\_ids | List of subnet IDs to deploy into | `list(string)` | n/a | yes |
| vpc\_id | ID of the VPC to deploy to | `string` | n/a | yes |
| worker\_desired\_capacity | Desired number of workers | `number` | n/a | yes |
| worker\_instance\_type | Instance type of the worker nodes | `string` | n/a | yes |
| worker\_max\_size | Maximum number of workers | `number` | n/a | yes |
| worker\_min\_size | Minimum number of workers | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_kubeconfig | KUBECONFIG yaml file contents to connect to the cluster. This should only be used by bots. Humans should use the KUBECONFIG that Rancher gives them. |
| elb\_dns\_name | DNS Name of the ELB that was created |
| elb\_zone\_id | Zone ID of the ELB that was created |
| ssh\_private\_key | Cluster nodes' private SSH key |
| ssh\_public\_key | Cluster nodes' public SSH key |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

[helm-operator]: https://github.com/fluxcd/helm-operator
[pre-commit]: https://pre-commit.com/
[tflint]: https://github.com/terraform-linters/tflint
[terraform-docs]: https://github.com/terraform-docs/terraform-docs
[tfsec]: https://github.com/liamg/tfsec
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[helm]: https://helm.sh/docs/intro/install/
[helmfile]: https://github.com/roboll/helmfile
[helm-diff]: https://github.com/databus23/helm-diff
[go-task]: https://taskfile.dev/#/
