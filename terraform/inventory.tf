resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.yml.tftpl", {
    attacker_mgmt_ip = module.attacker.primary_ipv4
    attacker_vm_id   = module.attacker.vm_id
    target_lab_ip    = module.target.primary_ipv4
    target_vm_id     = module.target.vm_id
  })
}
