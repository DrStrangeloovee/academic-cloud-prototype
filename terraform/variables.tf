variable "proxmox_endpoint" {
  description = "HTTPS URL of the Proxmox API, e.g. https://192.168.1.10:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (true for self-signed certs)"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name where the VM will be created"
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of the Cloud-Init template to clone from"
  type        = number
}

variable "vm_id" {
  description = "VM ID (e.g. 200)"
  type        = number
  default     = 200
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "my-vm"
}

variable "ssh_public_key" {
  description = "SSH public key to set"
  type        = string
}

variable "ipv4_configs" {
  description = "IPv4 config"
  type = list(object({
    address = string
    gateway = optional(string)
  }))
  default = [{ address = "dhcp" }]
}
