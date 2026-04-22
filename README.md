# Academic Cloud Prototype

**Stack:**
- OpenTofu:
    - Provider: [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- Ansible:
    - Collection: [community.proxmox](https://docs.ansible.com/projects/ansible/latest/collections/community/proxmox/index.html)

---

## Repository structure

```
terraform/      OpenTofu
ansible/        Ansible playbooks and inventory
scripts/        Helper scritps
```

## Requirements

All tools are managed by [mise](https://mise.jdx.dev/). Use `mise install` in the root directory to install everything: