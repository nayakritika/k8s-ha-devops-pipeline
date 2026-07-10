output "hv1_vms" {
  description = "Hypervisor 1 VM details"
  value = {
    vm1 = {
      name = module.hv1_vm1.vm_name
      id   = module.hv1_vm1.vm_id
    }
    vm2 = {
      name = module.hv1_vm2.vm_name
      id   = module.hv1_vm2.vm_id
    }
    vm3 = {
      name = module.hv1_vm3.vm_name
      id   = module.hv1_vm3.vm_id
    }
  }
}

output "hv2_vms" {
  description = "Hypervisor 2 VM details"
  value = {
    vm1 = {
      name = module.hv2_vm1.vm_name
      id   = module.hv2_vm1.vm_id
    }
    vm2 = {
      name = module.hv2_vm2.vm_name
      id   = module.hv2_vm2.vm_id
    }
    vm3 = {
      name = module.hv2_vm3.vm_name
      id   = module.hv2_vm3.vm_id
    }
  }
}

output "hv3_vms" {
  description = "Hypervisor 3 VM details"
  value = {
    vm1 = {
      name = module.hv3_vm1.vm_name
      id   = module.hv3_vm1.vm_id
    }
    vm2 = {
      name = module.hv3_vm2.vm_name
      id   = module.hv3_vm2.vm_id
    }
    vm3 = {
      name = module.hv3_vm3.vm_name
      id   = module.hv3_vm3.vm_id
    }
  }
}

output "hv4_vms" {
  description = "Hypervisor 4 VM details"
  value = {
    vm1 = {
      name = module.hv4_vm1.vm_name
      id   = module.hv4_vm1.vm_id
    }
    vm2 = {
      name = module.hv4_vm2.vm_name
      id   = module.hv4_vm2.vm_id
    }
    vm3 = {
      name = module.hv4_vm3.vm_name
      id   = module.hv4_vm3.vm_id
    }
  }
}
