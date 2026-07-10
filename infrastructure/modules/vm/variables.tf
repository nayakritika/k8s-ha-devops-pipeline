variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "base_volume_id" {
  description = "ID of the base volume to clone from"
  type        = string
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size in bytes"
  type        = number
  default     = 10737418240 # 10GB
}

variable "storage_pool" {
  description = "Storage pool name"
  type        = string
  default     = "default"
}

variable "bridge_name" {
  description = "Bridge name to attach to"
  type        = string
  default     = "kvmbr3"
}

variable "user_data" {
  description = "Cloud-init user data"
  type        = string
}

variable "network_config" {
  description = "Cloud-init network configuration"
  type        = string
}
