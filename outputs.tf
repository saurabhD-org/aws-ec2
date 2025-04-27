output "private_ip" {
  description = "List, primary private IPs of the instances"
  value       = aws_instance.this[*].private_ip
}

output "private_network_interfaces_ips" {
  description = "List, private IP addresses for the instances"
  value       = flatten(aws_network_interface.this[*].private_ip_list)
}

output "private_network_interfaces_arns" {
  description = "List, ARNs of the private network interfaces"
  value       = aws_network_interface.this[*].arn
}

output "private_network_interface_ids" {
  description = "List, IDs of the private network interfaces"
  value       = aws_network_interface.this[*].id
}

output "instance_names" {
  description = "List, instance names"
  value       = aws_instance.this[*].tags["Name"]
}

output "new_iam_role_arn" {
  description = "String, new IAM role ARN if created"
  value       = join(",", aws_iam_role.this[*].arn)
}

output "ec2_instance_arn" {
  description = "String, EC2 instance ARN if created"
  value       = join(",", aws_instance.this[*].arn)
}

output "existing_iam_role_arn" {
  description = "String, existing IAM role ARN"
  value       = join(",", data.aws_iam_role.this[*].arn)
}

output "ec2_instance_id" {
  description = "List, EC2 Instance IDs"
  value       = aws_instance.this[*].id
}

output "kms_key_id" {
  description = "String, ID of the KMS key used for encryption the root volume"
  value       = aws_kms_key.this.id
}

output "kms_key_arn" {
  description = "String, ARN of the KMS key used for encrypting the root volume"
  value       = aws_kms_key.this.arn
}

output "drive_name" {
  description = "Name of Additional EBS drives to be  created."
  value       = length(var.drive_names) > 0 ? var.drive_names : null
}