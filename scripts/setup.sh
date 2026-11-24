#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA="$ROOT/infrastructure"

prepare_environment() {
  local dir="$1"
  mkdir -p "$dir"
  find "$dir" -maxdepth 1 -type f -name "*.tf" -delete
  cp "$INFRA"/*.tf "$dir"/
  cd "$dir"
  terraform init -backend=false -input=false >/dev/null
}

prepare_environment "$ROOT/production"
terraform apply -auto-approve -input=false

prepare_environment "$ROOT/sandbox"
terraform apply -auto-approve -input=false

"$ROOT/scripts/validate-state.sh" "$ROOT/production/terraform.tfstate"
"$ROOT/scripts/validate-state.sh" "$ROOT/sandbox/terraform.tfstate"
