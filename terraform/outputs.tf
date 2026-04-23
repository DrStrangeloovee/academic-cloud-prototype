output "baseline_vm_id" {
  description = "VM ID"
  value       = module.baseline.vm_id
}

output "baseline_primary_ipv4" {
  description = "IPs of VM"
  value       = module.baseline.primary_ipv4
}
