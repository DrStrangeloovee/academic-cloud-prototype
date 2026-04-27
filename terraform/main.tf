module "attacker" {
  source = "./modules/vm"

  node_name      = var.proxmox_node
  template_vm_id = var.template_vm_id

  vm_id   = var.attacker_vm_id
  vm_name = "attacker"

  cores     = 2
  memory_mb = 2048

  network_devices = [
    { bridge = "vmbr0" },
    { bridge = "vmbr1" },
  ]

  ipv4_configs = [
    { address = var.attacker_mgmt_ipv4, gateway = var.attacker_mgmt_gateway },
    { address = var.attacker_lab_ipv4 },
  ]

  ssh_public_key   = var.ssh_public_key
  vm_user_password = var.vm_user_password
}

module "target" {
  source = "./modules/vm"

  node_name      = var.proxmox_node
  template_vm_id = var.template_vm_id

  vm_id   = var.target_vm_id
  vm_name = "target"

  cores     = 2
  memory_mb = 2048

  network_devices = [
    { bridge = "vmbr1" },
  ]

  ipv4_configs = [
    { address = var.target_lab_ipv4, gateway = var.target_lab_gateway },
  ]

  dns_servers = var.target_dns_servers

  ssh_public_key   = var.ssh_public_key
  vm_user_password = var.vm_user_password
}
