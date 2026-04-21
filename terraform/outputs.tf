output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_ipv4_address" {
  description = "IPs of VM"
  value       = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
