resource "aws_efs_file_system" "default" {
  throughput_mode = "bursting"
  encrypted       = true
  tags            = module.label.tags
}

resource "aws_efs_mount_target" "default" {
  for_each        = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = each.value
  security_groups = [aws_security_group.nfs.id]
}
