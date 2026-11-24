#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX="$ROOT/sandbox"

mkdir -p "$SANDBOX"
cp "$SANDBOX/terraform.tfstate" "$SANDBOX/migration-snapshot.tfstate"

cat > "$SANDBOX/concurrent.auto.tfvars" <<'EOF'
network_dns_suffix = "incident.prod.internal"
EOF

cat > "$SANDBOX/concurrent-resource.tf" <<'EOF'
resource "terraform_data" "application_server_canary" {
  input = {
    id              = "app-orders-canary-001"
    role            = "orders-api-canary"
    subnet_id       = terraform_data.private_subnet.input.id
    database_id     = terraform_data.database.input.id
    database_endpoint = terraform_data.database.input.endpoint
    instance_shape  = "synthetic-2cpu-4gb"
  }
  depends_on = [
    terraform_data.private_subnet,
    terraform_data.database,
  ]
}
EOF

cd "$SANDBOX"
terraform init -backend=false -input=false >/dev/null
terraform apply -auto-approve -input=false

python3 - "$SANDBOX/migration-snapshot.tfstate" "$SANDBOX/terraform.tfstate" <<'PY'
import json
import sys

snapshot, current = sys.argv[1:]
with open(snapshot, "r", encoding="utf-8") as handle:
    snapshot_state = json.load(handle)
with open(current, "r", encoding="utf-8") as handle:
    current_state = json.load(handle)

if current_state["serial"] <= snapshot_state["serial"]:
    raise SystemExit("concurrent deployment did not advance the Terraform state serial")

ids = set()
for resource in current_state.get("resources", []):
    for instance in resource.get("instances", []):
        data = (instance.get("attributes") or {}).get("input") or {}
        if isinstance(data, dict):
            data = data.get("value") or data
        if data.get("id"):
            ids.add(data["id"])

required = {"app-orders-canary-001"}
missing = required - ids
if missing:
    raise SystemExit("concurrent resource missing: " + ", ".join(sorted(missing)))

print("concurrency scenario valid: snapshot serial={}, current serial={}".format(
    snapshot_state["serial"], current_state["serial"]))
PY