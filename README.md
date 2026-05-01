# Academic Cloud Prototype

Bachelor thesis project: declaratively provisioning a two-VM pentest lab
on a Proxmox VE host with OpenTofu and Ansible.

**Stack:**
- OpenTofu (provider [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs))
- Ansible (collections [community.proxmox](https://docs.ansible.com/projects/ansible/latest/collections/community/proxmox/index.html), `community.general`, `ansible.posix`)

## Repository structure

```
terraform/   OpenTofu module + lab definition (attacker, target)
ansible/     Playbooks (platform check, site) and roles
benchmarks/  Benchmark and drift results
```

## Requirements

All tools are managed by [mise](https://mise.jdx.dev/). Use `mise install` in the root directory to install everything.