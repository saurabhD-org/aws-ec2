resource "aws_instance" "this" {
  count         = var.counts
  ami           = var.ami
  instance_type = var.instance_type
  monitoring    = true
  tags = merge(var.tags, {
    Name = "aws-${element(data.aws_availability_zones.this.zone_ids, count.index % length(data.aws_availability_zones.this.zone_ids))}-${var.name}-${format("%02d", count.index + 1)}"
  })

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
  }

  iam_instance_profile = var.iam_role == "" ? aws_iam_instance_profile.this[0].name : data.aws_iam_role.this[0].name

  key_name = var.key_name != "" ? var.key_name : null

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 1
  }
  root_block_device {
    encrypted   = true
    volume_size = var.disk_size
    kms_key_id  = aws_kms_key.this.arn
  }

  dynamic "network_interface" {
    for_each = range(var.number_of_interfaces)
    content {
      network_interface_id = aws_network_interface.this[count.index * var.number_of_interfaces + network_interface.key].id
      device_index         = network_interface.key
    }
  }

  user_data_base64            = base64encode(var.user_data)
  user_data_replace_on_change = true

}

resource "aws_kms_key" "this" {
  description             = "KMS Key for EC2 ${var.name}"
  enable_key_rotation     = true
  tags                    = var.tags
  deletion_window_in_days = 30
  policy                  = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "default",
    "Statement": [
      {
        "Sid": "DefaultAllow",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
POLICY
}

resource "aws_iam_instance_profile" "this" {
  count = var.iam_role == "" && var.create_new_role ? 1 : 0
  name  = var.new_instance_profile_name != "" ? "ec2-${var.name}-${var.subnet_id}-${var.new_instance_profile_name}" : "ec2-${var.name}-${var.subnet_id}"
  role  = aws_iam_role.this[0].name
  tags  = var.tags
}

resource "aws_iam_role" "this" {
  count              = var.iam_role == "" && var.create_new_role ? 1 : 0
  name               = var.new_role != "" ? "ec2-${var.name}-${var.subnet_id}-${var.new_role}" : "ec2-${var.name}-${var.subnet_id}"
  assume_role_policy = file("${path.module}/role_policy.json")
  tags               = var.tags

}

resource "aws_iam_policy" "this" {
  count  = var.iam_role == "" && var.create_new_role ? 1 : 0
  name   = var.iam_policy_name != "" ? "ec2-${var.name}-${var.subnet_id}-${var.iam_policy_name}" : "ec2-${var.name}-${var.subnet_id}"
  policy = file("${path.module}/iam-policy.json")
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.iam_role == "" && var.create_new_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_network_interface" "this" {
  count             = var.counts * var.number_of_interfaces
  subnet_id         = var.subnet_id
  security_groups   = var.security_group_ids
  tags              = var.tags
  private_ips_count = var.additional_ips
}

resource "aws_ebs_volume" "this" {
  depends_on        = [aws_instance.this]
  count             = length(var.drive_names) == 0 ? 0 : length(var.drive_names)
  encrypted         = true
  availability_zone = data.aws_subnet.this.availability_zone
  size              = 10
}

resource "aws_volume_attachment" "this" {
  depends_on  = [aws_instance.this]
  count       = length(var.drive_names) == 0 ? 0 : length(var.drive_names)
  device_name = "xvd${element(["f", "g", "h", "i", "j", "k", "l", "m", "n", "o"], count.index)}"
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = aws_instance.this[0].id
}