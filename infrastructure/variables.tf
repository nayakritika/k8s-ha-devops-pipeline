variable "ubuntu_image_url" {
  description = "URL to Ubuntu cloud image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "storage_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "vm_memory" {
  description = "Memory allocation for each VM in MB"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk size for each VM in bytes"
  type        = number
  default     = 10737418240 # 10GB
}
