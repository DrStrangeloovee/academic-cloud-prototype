output "vm_id" {
  description = "VM ID"
  value       = module.spike.vm_id
}

output "vm_ipv4_address" {
  description = "IPs of VM"
  value       = module.spike.ipv4_addresses
}
