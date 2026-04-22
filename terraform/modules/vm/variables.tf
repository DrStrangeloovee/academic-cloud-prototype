variable "node_name" {
  description = "Proxmox node name to deploy VM to"
  type        = string
}

variable "vm_id" {
  description = "´VM ID in Proxmox"
  type        = number
}

variable "vm_name" {
  description = "Display name of the VM"
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of the Cloud-Init template to clone from"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH public key injected via Cloud-Init"
  type        = string
}

variable "vm_username" {
  description = "Cloud-Init default user"
  type        = string
  default     = "debian"
}

variable "cores" {
  description = "Number of vCPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "RAM in MiB"
  type        = number
  default     = 1024
}

variable "disk_size_gb" {
  description = "Root disk size in GiB"
  type        = number
  default     = 10
}

variable "datastore_id" {
  description = "Proxmox datastore for disk and Cloud-Init drive"
  type        = string
  default     = "local-lvm"
}

variable "clone_full" {
  description = "Full clone (true) | linked clone (false)"
  type        = bool
  default     = false
}

variable "network_devices" {
  description = "List of NICs to attach -> ipv4_configs[0]."
  type = list(object({
    bridge = string
    model  = optional(string, "virtio")
  }))
  default = [{ bridge = "vmbr0" }]
}

variable "ipv4_configs" {
  description = "Cloud-Init IPv4 config per NIC. Use address = \"dhcp\" for DHCP, or an address e.g. \"192.168.1.x/24\". List length must match network_devices."
  type = list(object({
    address = string
    gateway = optional(string)
  }))
  default = [{ address = "dhcp" }]

  validation {
    condition     = length(var.ipv4_configs) > 0
    error_message = "ipv4_configs must have at least one entry."
  }
}
