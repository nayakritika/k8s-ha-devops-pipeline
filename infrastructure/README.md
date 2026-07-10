# Terraform Libvirt Setup

This Terraform project provisions 12 Ubuntu VMs (3 per hypervisor) across 4 hypervisors using libvirt.

## Architecture

- **Hypervisors**: 4 hosts at 10.13.37.1, 10.13.37.2, 10.13.37.3, 10.13.37.4
- **VMs per hypervisor**: 2
- **Total VMs**: 8
- **VM specs**: 2 vCPUs, 2GB RAM, 10GB disk
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **Network**: Bridge mode using kvmbr3
- **Networking**: Static IP addressing (10.13.37.0/24)

### Cloud-Init Configuration

Each VM has its own cloud-init configuration files:

1. **network-config-vmX.yaml**: Static IP configuration for each VM
   - Pre-configured with unique static IPs on 10.13.37.0/24 network
   - Using bridge kvmbr3
   - Gateway: Set to the hosting hypervisor IP (VM1/VM2 → 10.13.37.1, VM3/VM4 → 10.13.37.2, etc.)
   - No DNS servers configured (inherit from system or configure separately)

2. **user-data-vmX.yaml**: Individual VM configuration
   - Unique hostname (VM1 through VM8)
   - SSH key authentication only (password auth disabled)
   - Default user: ubuntu (sudo access)
   - Includes qemu-guest-agent and common utilities
