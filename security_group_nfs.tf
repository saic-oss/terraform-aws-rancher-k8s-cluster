data "aws_subnet" "default" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

resource "aws_security_group" "nfs" {
  name_prefix = "${module.label.id}-nfs"
  description = "Allow NFS traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = values(data.aws_subnet.default)[*].cidr_block
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = values(data.aws_subnet.default)[*].cidr_block
  }

  tags = module.label.tags
}
