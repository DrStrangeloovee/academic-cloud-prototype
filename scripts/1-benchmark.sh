#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

ITERATIONS="${1:-5}"
VM_IP="${VM_IP:-192.168.1.50}"
OUT="spike-bench-$(date -u +%Y%m%dT%H%M%SZ).txt"

echo "iter apply ssh_wait ansible destroy total" > "$OUT"
for i in $(seq 1 "$ITERATIONS"); do
  ssh-keygen -R "$VM_IP" >/dev/null 2>&1 || true
  t0=$(date +%s)
  (cd terraform && tofu apply -auto-approve)
  t1=$(date +%s)
  until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes debian@"$VM_IP" true 2>/dev/null; do sleep 2; done
  t2=$(date +%s)
  (cd ansible && ansible-playbook playbooks/validate.yml)
  t3=$(date +%s)
  (cd terraform && tofu destroy -auto-approve)
  t4=$(date +%s)
  echo "$i $((t1-t0)) $((t2-t1)) $((t3-t2)) $((t4-t3)) $((t4-t0))" | tee -a "$OUT"
done
