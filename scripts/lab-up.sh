#!/usr/bin/env bash
# Provision the pentest lab:
#   1) preflight
#   2) tofu apply
#   3) ansible site.yml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

TFVARS="terraform/terraform.tfvars"
if [[ ! -f "$TFVARS" ]]; then
  echo "ERROR: $TFVARS missing. Copy terraform.tfvars.example and fill it in." >&2
  exit 1
fi

# preflight.yml reads its config via lookup('env', 'PROXMOX_*'); parse
_tfvar()     { grep -E "^\s*$1\s*=" "$TFVARS" | head -1 | sed -E 's/^[^=]+=\s*"([^"]*)".*/\1/'; }
_tfvar_int() { grep -E "^\s*$1\s*=" "$TFVARS" | head -1 | sed -E 's/^[^=]+=\s*([0-9]+).*/\1/'; }

# endpoint=https://host:port/ -> host
endpoint=$(_tfvar proxmox_endpoint)
host=$(echo "$endpoint" | sed -E 's|^https?://||; s|:[0-9]+.*||; s|/.*||')

# token=user@realm!tokenid=secret -> user, tokenid, secret
token=$(_tfvar proxmox_api_token)
user=${token%%!*}
rest=${token#*!}
tokenid=${rest%%=*}
secret=${rest#*=}

if [[ -z "$host" || -z "$user" || -z "$tokenid" || -z "$secret" ]]; then
  echo "ERROR: could not parse proxmox_endpoint/proxmox_api_token from $TFVARS." >&2
  exit 1
fi

export PROXMOX_HOST="$host"
export PROXMOX_USER="$user"
export PROXMOX_TOKEN_ID="$tokenid"
export PROXMOX_TOKEN_SECRET="$secret"
export PROXMOX_NODE="$(_tfvar proxmox_node)"
export PROXMOX_TEMPLATE_VM_ID="$(_tfvar_int template_vm_id)"

echo "==> [1/3] Preflight"
ansible-playbook ansible/playbooks/preflight.yml

echo "==> [2/3] tofu apply"
tofu -chdir=terraform init -input=false
tofu -chdir=terraform apply -auto-approve -input=false

ATTACKER_IP=$(tofu -chdir=terraform output -raw attacker_mgmt_ipv4)
TARGET_IP=$(tofu -chdir=terraform output -raw target_lab_ipv4)

# After destroy/apply the VMs get new host keys, the old ones are removed
ssh-keygen -R "$ATTACKER_IP" >/dev/null 2>&1 || true
ssh-keygen -R "$TARGET_IP"   >/dev/null 2>&1 || true

SSH_OPTS=(-o BatchMode=yes -o StrictHostKeyChecking=no
          -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)

echo "==> Wait for SSH on attacker ($ATTACKER_IP)"
for _ in $(seq 1 24); do
  ssh "${SSH_OPTS[@]}" debian@"$ATTACKER_IP" true 2>/dev/null && break
  sleep 5
done

echo "==> Wait for SSH on target ($TARGET_IP via attacker)"
TARGET_PROXY="ssh -W %h:%p -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 debian@$ATTACKER_IP"
for _ in $(seq 1 24); do
  ssh "${SSH_OPTS[@]}" -o "ProxyCommand=$TARGET_PROXY" debian@"$TARGET_IP" true 2>/dev/null && break
  sleep 5
done

echo "==> [3/3] ansible site.yml"
ansible-playbook ansible/playbooks/site.yml

cat <<EOF

Lab ready.
  Attacker (mgmt):  ssh debian@$ATTACKER_IP
  Target (lab):     curl -I http://$TARGET_IP:3000   (run from attacker)
  Destroy:        ./scripts/lab-down.sh
EOF
