output "vm_id" {
  description = "ID of the created VM"
  value       = libvirt_domain.vm.id
}

output "vm_name" {
  description = "Name of the created VM"
  value       = libvirt_domain.vm.name
}

output "vm_network_interfaces" {
  description = "Network interfaces of the VM"
  value       = libvirt_domain.vm.network_interface
}
