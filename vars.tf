variable "name" {
  type        = string
  description = "Name of the EC2 instance"
}

variable "ami" {
  type        = string
  description = "AMI for the EC2 instance"
}

variable "tags" {
  type        = map(any)
  description = "Tags for the EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the EC2 instance"
}

variable "counts" {
  type        = number
  default     = 1
  description = "Number of EC2 instances to create"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type of EC2 instance"
}

variable "source_dest_check" {
  type        = bool
  default     = true
  description = "Source/Destination Check for the EC2 instance"
}

variable "user_data" {
  type        = string
  description = "User data for the EC2 instance"
}

variable "cpu_options" {
  type = object({
    core_count       = number
    threads_per_core = number
  })
  default     = null
  description = "CPU options for the EC2 instance"
}

variable "iam_role" {
  type        = string
  description = "Enter an IAM role name that you want to attach. If you want to create a new role leave empty"
  default     = ""
}

variable "new_role" {
  type        = string
  description = "Custom role name for the EC2"
  default     = ""
}

variable "create_new_role" {
  type        = bool
  description = "Set it as true if you want to create new role"
  default     = true
}

variable "iam_policy_name" {
  type        = string
  description = "Custom policy name for the IAM role"
  default     = ""
}

variable "new_instance_profile_name" {
  type        = string
  description = "Custom instance profile name"
  default     = ""
}

variable "disk_size" {
  type        = number
  default     = 80
  description = "Disk size for the launched instance root volume"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs to associate to the instance (maximum five)"
  validation {
    condition     = length(var.security_group_ids) <= 5
    error_message = "Security Group IDs must be five or less"
  }
}

variable "key_name" {
  type        = string
  description = "Key ID used for SSH/RDP access to the EC2 instance, leave blank for none"
  default     = ""
}

variable "domain_id" {
  type        = string
  description = "ID of the AWS Directory Services Domain to join"
  default     = ""
}

variable "number_of_interfaces" {
  type        = number
  default     = 1
  description = "Number of interfaces to assign to the EC2 instance in the provided subnet"
}

variable "additional_ips" {
  type        = number
  default     = 0
  description = "Number of additional IP addresses to assign to the EC2 instance in the provided subnet"
}

variable "drive_names" {
  description = "List of Drive Name to create and attach to ec2."
  type        = list(string)
  default     = []
}