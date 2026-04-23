resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"

  content = yamlencode({
    all = {
      hosts = {
        (var.baseline_vm_name) = {
          ansible_host = module.baseline.primary_ipv4
          proxmox_vmid = module.baseline.vm_id
        }
      }
    }
  })
}
