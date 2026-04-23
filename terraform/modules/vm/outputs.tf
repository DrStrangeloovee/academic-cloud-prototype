output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "primary_ipv4" {
  description = "Primary IPv4 address of the first NIC"
  value       = split("/", var.ipv4_configs[0].address)[0]
}

output "ipv4_addresses_state" {
  description = "IPv4 addresses from QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}
