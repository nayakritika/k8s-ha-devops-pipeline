terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.0, < 0.8.0"
    }
  }

  backend "http" {
    address        = "https://gitlab.os3.nl/api/v4/projects/863/terraform/state/dev"
    lock_address   = "https://gitlab.os3.nl/api/v4/projects/863/terraform/state/dev/lock"
    unlock_address = "https://gitlab.os3.nl/api/v4/projects/863/terraform/state/dev/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }
}

# Provider configurations for each hypervisor
provider "libvirt" {
  alias = "hv1"
  uri   = "qemu+ssh://alabonte@10.13.37.1/system"
}

provider "libvirt" {
  alias = "hv2"
  uri   = "qemu+ssh://nikita@10.13.37.2/system"
}

provider "libvirt" {
  alias = "hv3"
  uri   = "qemu+ssh://ritika@10.13.37.3/system"
}

provider "libvirt" {
  alias = "hv4"
  uri   = "qemu+ssh://maudenaert@10.13.37.4:22345/system"
}

# Ubuntu cloud image volume (shared base image for all VMs)
resource "libvirt_volume" "ubuntu_base_hv1" {
  provider = libvirt.hv1
  name     = "ubuntu-base.qcow2"
  pool     = var.storage_pool
  source   = var.ubuntu_image_url
}

resource "libvirt_volume" "ubuntu_base_hv2" {
  provider = libvirt.hv2
  name     = "ubuntu-base.qcow2"
  pool     = var.storage_pool
  source   = var.ubuntu_image_url
}

resource "libvirt_volume" "ubuntu_base_hv3" {
  provider = libvirt.hv3
  name     = "ubuntu-base.qcow2"
  pool     = var.storage_pool
  source   = var.ubuntu_image_url
}

resource "libvirt_volume" "ubuntu_base_hv4" {
  provider = libvirt.hv4
  name     = "ubuntu-base.qcow2"
  pool     = var.storage_pool
  source   = var.ubuntu_image_url
}

# Hypervisor 1 VMs (10.13.37.1)
# VM1 - IP: 10.13.37.11, Hostname: VM1
module "hv1_vm1" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv1
  }

  vm_name          = "hv1-vm1"
  base_volume_id   = libvirt_volume.ubuntu_base_hv1.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm1.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm1.yaml")
}

# VM2 - IP: 10.13.37.12, Hostname: VM2
module "hv1_vm2" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv1
  }

  vm_name          = "hv1-vm2"
  base_volume_id   = libvirt_volume.ubuntu_base_hv1.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm2.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm2.yaml")
}

# VM9 – IP: 10.13.37.13, Hostname: VM9
module "hv1_vm3" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv1
  }

  vm_name          = "hv1-vm3"
  base_volume_id   = libvirt_volume.ubuntu_base_hv1.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm9.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm9.yaml")
}

# Hypervisor 2 VMs (10.13.37.2)
# VM3 - IP: 10.13.37.21, Hostname: VM3
module "hv2_vm1" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv2
  }

  vm_name          = "hv2-vm1"
  base_volume_id   = libvirt_volume.ubuntu_base_hv2.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm3.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm3.yaml")
}

# VM4 - IP: 10.13.37.22, Hostname: VM4
module "hv2_vm2" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv2
  }

  vm_name          = "hv2-vm2"
  base_volume_id   = libvirt_volume.ubuntu_base_hv2.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm4.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm4.yaml")
}

# VM10 – IP: 10.13.37.23, Hostname: VM10
module "hv2_vm3" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv2
  }

  vm_name          = "hv2-vm3"
  base_volume_id   = libvirt_volume.ubuntu_base_hv2.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm10.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm10.yaml")
}

# Hypervisor 3 VMs (10.13.37.3)
# VM5 - IP: 10.13.37.31, Hostname: VM5
module "hv3_vm1" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv3
  }

  vm_name          = "hv3-vm1"
  base_volume_id   = libvirt_volume.ubuntu_base_hv3.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm5.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm5.yaml")
}

# VM6 - IP: 10.13.37.32, Hostname: VM6
module "hv3_vm2" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv3
  }

  vm_name          = "hv3-vm2"
  base_volume_id   = libvirt_volume.ubuntu_base_hv3.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm6.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm6.yaml")
}

# VM11 – IP: 10.13.37.33, Hostname: VM11
module "hv3_vm3" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv3
  }

  vm_name          = "hv3-vm3"
  base_volume_id   = libvirt_volume.ubuntu_base_hv3.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm11.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm11.yaml")
}

# Hypervisor 4 VMs (10.13.37.4)
# VM7 - IP: 10.13.37.41, Hostname: VM7
module "hv4_vm1" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv4
  }

  vm_name          = "hv4-vm1"
  base_volume_id   = libvirt_volume.ubuntu_base_hv4.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm7.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm7.yaml")
}

# VM8 - IP: 10.13.37.42, Hostname: VM8
module "hv4_vm2" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv4
  }

  vm_name          = "hv4-vm2"
  base_volume_id   = libvirt_volume.ubuntu_base_hv4.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm8.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm8.yaml")
}

# VM12 – IP: 10.13.37.43, Hostname: VM12
module "hv4_vm3" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt.hv4
  }

  vm_name          = "hv4-vm3"
  base_volume_id   = libvirt_volume.ubuntu_base_hv4.id
  vcpu             = 2
  memory           = var.vm_memory
  disk_size        = var.vm_disk_size
  storage_pool     = var.storage_pool
  bridge_name      = "kvmbr3"
  network_config   = file("${path.module}/cloud-init/network-config-vm12.yaml")
  user_data        = file("${path.module}/cloud-init/user-data-vm12.yaml")
}
