resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.proxmox_node
  vm_id     = var.vm_id

  clone {
    vm_id = var.template_vm_id
    full  = false # linked clone (COW)
  }

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 10
    discard      = "on"
    iothread     = true # If true needs: 'scsi_hardware = "virtio-scsi-single"'
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Cloud-Init drive
  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "debian"
      keys     = [var.ssh_public_key]
    }
  }

  # QEMU agent
  agent {
    enabled = true
    timeout = "2m"
  }

  started = true
}
