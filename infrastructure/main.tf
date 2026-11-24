terraform {
  required_version = ">= 1.6.0"
}

variable "database_capacity_gb" {
  description = "Provisioned synthetic database capacity."
  type        = number
  default     = 100
}

variable "network_dns_suffix" {
  description = "Synthetic DNS suffix used by network security configuration."
  type        = string
  default     = "prod.internal"
}