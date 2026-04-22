resource "proxmox_virtual_environment_vm" "this" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  clone {
    vm_id = var.template_vm_id
    full  = var.clone_full
  }

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size_gb
    discard      = "on"
    iothread     = true
  }

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge = network_device.value.bridge
      model  = network_device.value.model
    }
  }

  initialization {
    datastore_id = var.datastore_id

    dynamic "ip_config" {
      for_each = var.ipv4_configs
      content {
        ipv4 {
          address = ip_config.value.address
          gateway = ip_config.value.gateway
        }
      }
    }

    user_account {
      username = var.vm_username
      keys     = [var.ssh_public_key]
    }
  }

  agent {
    enabled = true
    timeout = "2m"
  }

  started = true
}
