provider "aws" {}

provider "random" {}

provider "tls" {}

provider "rancher2" {
  alias = "admin"
}
