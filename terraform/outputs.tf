output "attacker_vm_id" {
  description = "Proxmox VM ID of the attacker VM"
  value       = module.attacker.vm_id
}

output "attacker_mgmt_ipv4" {
  description = "Attacker management IP on vmbr0"
  value       = module.attacker.primary_ipv4
}

output "attacker_lab_ipv4" {
  description = "Attacker IP on vmbr1"
  value       = split("/", var.attacker_lab_ipv4)[0]
}

output "target_vm_id" {
  description = "Proxmox VM ID of the target VM"
  value       = module.target.vm_id
}

output "target_lab_ipv4" {
  description = "Target IP on vmbr1"
  value       = module.target.primary_ipv4
}
