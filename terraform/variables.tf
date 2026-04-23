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
  description = "VM ID of the Cloud-Init template to clone from (Debian 13)"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH public key to set"
  type        = string
}

variable "vm_user_password" {
  description = "Password for the Cloud-Init default user"
  type        = string
  sensitive   = true
}

variable "baseline_vm_id" {
  description = "VM ID (e.g. 200)"
  type        = number
  default     = 200
}

variable "baseline_vm_name" {
  description = "Hostname of the VM"
  type        = string
  default     = "baseline"
}

variable "baseline_ipv4_configs" {
  description = "IPv4 config"
  type = list(object({
    address = string
    gateway = optional(string)
  }))
  default = [{ address = "dhcp" }]
}
