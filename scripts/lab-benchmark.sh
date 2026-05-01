#!/usr/bin/env bash
# Benchmark: N iterations of apply/ssh_wait/ansible/destroy

set -euo pipefail
cd "$(dirname "$0")/.."

N=${1:-5}  # iterations, default 5
OUT="benchmarks/lab-bench-$(date -u +%Y%m%dT%H%M%SZ).txt"
mkdir -p benchmarks
echo "iter apply ssh_wait ansible destroy total" > "$OUT"

SSH_OPTS=(-o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)

for i in $(seq 1 "$N"); do
  # apply: clone both VMs, generate inventory
  t0=$(date +%s)
  tofu -chdir=terraform apply -auto-approve -input=false >/dev/null
  t1=$(date +%s)

  # ssh_wait: drop old key and wait for response from ssh
  ip=$(tofu -chdir=terraform output -raw attacker_mgmt_ipv4)
  ssh-keygen -R "$ip" >/dev/null 2>&1 || true
  until ssh "${SSH_OPTS[@]}" debian@"$ip" true 2>/dev/null; do sleep 2; done
  t2=$(date +%s)

  # ansible: common, lab-router, juice-shop, kali-tools
  ansible-playbook ansible/playbooks/site.yml >/dev/null
  t3=$(date +%s)

  # destroy: remove VMs
  tofu -chdir=terraform destroy -auto-approve >/dev/null
  t4=$(date +%s)

  echo "$i $((t1-t0)) $((t2-t1)) $((t3-t2)) $((t4-t3)) $((t4-t0))" | tee -a "$OUT"
done
