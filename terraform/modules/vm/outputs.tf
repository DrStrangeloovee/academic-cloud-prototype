output "vm_id" {
  description = "VM ID in Proxmox"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name in Proxmox"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_addresses" {
  description = "IPv4 addresses retrieved from QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}
