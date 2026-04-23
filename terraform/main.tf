module "baseline" {
  source = "./modules/vm"

  node_name = var.proxmox_node
  template_vm_id = var.template_vm_id

  vm_id = var.baseline_vm_id
  vm_name = var.baseline_vm_name

  network_devices = [
    { bridge = "vmbr0" },
  ]
  ipv4_configs = var.baseline_ipv4_configs

  ssh_public_key = var.ssh_public_key
  vm_user_password = var.vm_user_password
}
