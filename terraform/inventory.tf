resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"
  content = yamlencode({
    all = {
      hosts = {
        (var.vm_name) = {
          ansible_host = split("/", var.ipv4_configs[0].address)[0]
        }
      }
    }
  })
}
