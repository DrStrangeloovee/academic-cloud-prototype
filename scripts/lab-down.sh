#!/usr/bin/env bash
# Destroy the pentest lab

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

tofu -chdir="$REPO_ROOT/terraform" destroy -auto-approve
