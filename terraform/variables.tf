variable "my_ip_cidr" {
  type = string
}

variable "email" {
  description = "The email to use for the 'Owner' tag."
  type        = string
}

variable "keyname" {
  description = "The SSH Key in AWS to use for the EC2 Instances"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR to use for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR to use for the subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "redhat_username" {
  description = "Your Red Hat username. Used for the Inventory file."
  type        = string
}

variable "redhat_password" {
  description = "Your Red Hat password. Used for the Inventory file."
  type        = string
  sensitive   = true
}

variable "customer" {
  description = "Customer Name to use in resource names"
  type        = string
  default     = "lab"
}

variable "vault_count" {
  description = "Number of vault nodes"
  type        = number
  default     = 1
}
