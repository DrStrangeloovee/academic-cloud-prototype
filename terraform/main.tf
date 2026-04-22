module "spike" {
  source = "./modules/vm"

  node_name      = var.proxmox_node
  vm_id          = var.vm_id
  vm_name        = var.vm_name
  template_vm_id = var.template_vm_id
  ssh_public_key = var.ssh_public_key
  ipv4_configs   = var.ipv4_configs
}
