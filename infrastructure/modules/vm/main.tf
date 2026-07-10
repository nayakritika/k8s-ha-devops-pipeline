terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# Create a volume for this VM based on the base image
resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_name}.qcow2"
  base_volume_id = var.base_volume_id
  pool           = var.storage_pool
  size           = var.disk_size
  format         = "qcow2"

}

# Create cloud-init disk
resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "${var.vm_name}-cloudinit.iso"
  pool           = var.storage_pool
  user_data      = var.user_data
  network_config = var.network_config
}

# Define the VM
resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.memory
  vcpu   = var.vcpu
  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    bridge         = var.bridge_name
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
