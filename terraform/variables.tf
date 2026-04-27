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
  description = "Proxmox node name where VMs are created"
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

variable "attacker_vm_id" {
  description = "Proxmox VM ID for the attacker VM"
  type        = number
  default     = 210
}

variable "attacker_mgmt_ipv4" {
  description = "Attacker management IP on vmbr0"
  type        = string
}

variable "attacker_mgmt_gateway" {
  description = "Gateway of the attacker on vmbr0"
  type        = string
}

variable "attacker_lab_ipv4" {
  description = "Attacker IP on vmbr1"
  type        = string
  default     = "10.10.10.10/24"
}

variable "target_vm_id" {
  description = "Proxmox VM ID of the target VM"
  type        = number
  default     = 220
}

variable "target_lab_ipv4" {
  description = "Target IP on vmbr1"
  type        = string
  default     = "10.10.10.20/24"
}

variable "target_lab_gateway" {
  description = "Default gateway for target (attacker lab IP for NAT to vmbr0)"
  type        = string
  default     = "10.10.10.10"
}

variable "target_dns_servers" {
  description = "DNS servers to use for target"
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}
