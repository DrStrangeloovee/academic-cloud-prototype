variable "node_name" {
  description = "Proxmox node name to deploy VM to"
  type        = string
}

variable "vm_id" {
  description = "´VM ID in Proxmox"
  type        = number
}

variable "vm_name" {
  description = "Display name and hostname of the VM"
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of the Cloud-Init template to clone from"
  type        = number
}

variable "clone_full" {
  description = "Full clone (true) or linked clone (false)"
  type        = bool
  default     = false
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

variable "network_devices" {
  description = "List of NICs to attach -> ipv4_configs[i]"
  type = list(object({
    bridge = string
    model  = optional(string, "virtio")
  }))

  validation {
    condition     = length(var.network_devices) > 0
    error_message = "At least one network_device is required"
  }
}

variable "ipv4_configs" {
  description = "Cloud-Init IPv4 configuration. List length must equal network_devices. Use address = \"dhcp\" for DHCP or CIDR notation (e.g. \"10.10.10.10\\/24\")"
  type = list(object({
    address = string
    gateway = optional(string)
  }))

  validation {
    condition     = length(var.ipv4_configs) > 0
    error_message = "ipv4_configs must have at least one entry."
  }
}

variable "vm_username" {
  description = "Cloud-Init default user"
  type        = string
  default     = "debian"
}

variable "vm_user_password" {
  description = "Password for the Cloud-Init user"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH key for vm_username"
  type        = string
}
