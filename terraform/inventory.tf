resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"

  content = yamlencode({
    all = {
      hosts = {
        attacker = {
          ansible_host = module.attacker.primary_ipv4
          proxmox_vmid = module.attacker.vm_id
        }
        target = {
          ansible_host = split("/", var.target_lab_ipv4)[0]
          proxmox_vmid = module.target.vm_id
        }
      }
    }
  })
}
