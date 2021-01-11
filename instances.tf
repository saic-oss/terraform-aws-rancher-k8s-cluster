data "template_file" "controlplane_userdata" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    node_join_command = "${rancher2_cluster.default.cluster_registration_token[0].node_command} --etcd --controlplane"
  }
  depends_on = [
    rancher2_cluster.default
  ]
}

data "template_file" "worker_userdata" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    node_join_command = "${rancher2_cluster.default.cluster_registration_token[0].node_command} --worker"
  }
  depends_on = [
    rancher2_cluster.default
  ]
}

resource "aws_launch_template" "controlplane" {
  name_prefix = "${module.label.id}-controlplane"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = "true"
      volume_size           = var.node_volume_size
      volume_type           = "gp2"
      encrypted             = "false"
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }
  description   = "Launch template for K8s control plane node managed by Rancher"
  ebs_optimized = true
  image_id      = local.controlplane_image_id
  instance_type = var.controlplane_instance_type
  key_name      = aws_key_pair.ssh.id
  metadata_options {
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }
  monitoring {
    enabled = var.enable_detailed_monitoring
  }
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.nodes.id]
  }
  tag_specifications {
    resource_type = "instance"

    tags = module.label.tags
  }
  user_data              = base64encode(data.template_file.controlplane_userdata.rendered)
  update_default_version = true
  depends_on = [
    rancher2_cluster.default,
    data.template_file.controlplane_userdata
  ]
}

resource "aws_launch_template" "worker" {
  name_prefix = "${module.label.id}-worker"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = "true"
      volume_size           = var.node_volume_size
      volume_type           = "gp2"
      encrypted             = "false"
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }
  description   = "Launch template for K8s worker node managed by Rancher"
  ebs_optimized = true
  image_id      = local.worker_image_id
  instance_type = var.worker_instance_type
  key_name      = aws_key_pair.ssh.id
  metadata_options {
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }
  monitoring {
    enabled = var.enable_detailed_monitoring
  }
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.nodes.id]
  }
  tag_specifications {
    resource_type = "instance"

    tags = module.label.tags
  }
  user_data              = base64encode(data.template_file.worker_userdata.rendered)
  update_default_version = true
  depends_on = [
    rancher2_cluster.default,
    data.template_file.worker_userdata
  ]
}

resource "aws_autoscaling_group" "controlplane" {
  name_prefix               = "${module.label.id}-controlplane"
  max_size                  = 3
  min_size                  = 3
  desired_capacity          = 3
  health_check_grace_period = 600
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.controlplane.id
    version = "$Latest"
  }
  vpc_zone_identifier   = var.subnet_ids
  termination_policies  = ["OldestInstance"]
  protect_from_scale_in = var.protect_from_scale_in
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${module.label.id}-controlplane"
  }
  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }
  depends_on = [
    aws_launch_template.controlplane
  ]
}

resource "aws_autoscaling_group" "worker" {
  name_prefix               = "${module.label.id}-worker"
  max_size                  = var.worker_max_size
  min_size                  = var.worker_min_size
  desired_capacity          = var.worker_desired_capacity
  health_check_grace_period = 600
  health_check_type         = "ELB"
  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }
  vpc_zone_identifier   = var.subnet_ids
  termination_policies  = ["OldestInstance"]
  protect_from_scale_in = var.protect_from_scale_in
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${module.label.id}-worker"
  }
  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }
  depends_on = [
    aws_launch_template.worker
  ]
}

resource "aws_autoscaling_attachment" "worker" {
  autoscaling_group_name = aws_autoscaling_group.worker.id
  elb                    = aws_elb.ingress.id
  depends_on = [
    aws_autoscaling_group.worker,
    aws_elb.ingress
  ]
}
