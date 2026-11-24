#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/scripts/reset.sh"
terraform -chdir="$ROOT/infrastructure" fmt -check >/dev/null
terraform -chdir="$ROOT/infrastructure" validate

"$ROOT/scripts/validate-state.sh" "$ROOT/production/terraform.tfstate"
"$ROOT/scripts/validate-state.sh" "$ROOT/sandbox/terraform.tfstate"

python3 - "$ROOT/production/terraform.tfstate" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    state = json.load(handle)

found = False
for resource in state["resources"]:
    if resource["type"] == "terraform_data" and resource["name"] == "database":
        data = resource["instances"][0]["attributes"]["input"]
        if isinstance(data, dict):
            data = data.get("value") or data
        found = data["capacity_gb"] == 200
if not found:
    raise SystemExit("emergency database capacity is missing")
PY

prod_before="$(sha256sum "$ROOT/production/terraform.tfstate" | cut -d' ' -f1)"
"$ROOT/scripts/simulate-deployment.sh"
prod_after="$(sha256sum "$ROOT/production/terraform.tfstate" | cut -d' ' -f1)"
test "$prod_before" = "$prod_after"

python3 - "$ROOT/sandbox/migration-snapshot.tfstate" "$ROOT/sandbox/terraform.tfstate" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as snapshot:
    old = json.load(snapshot)
with open(sys.argv[2], "r", encoding="utf-8") as current:
    new = json.load(current)

if new["serial"] <= old["serial"]:
    raise SystemExit("concurrent deployment did not advance serial")

ids = set()
for resource in new["resources"]:
    for inst in resource["instances"]:
        data = (inst.get("attributes") or {}).get("input") or {}
        if isinstance(data, dict):
            data = data.get("value") or data
        if data.get("id"):
            ids.add(data["id"])
if "app-orders-canary-001" not in ids:
    raise SystemExit("concurrent application resource is missing")
PY

"$ROOT/scripts/reset.sh"
"$ROOT/scripts/validate-state.sh" "$ROOT/production/terraform.tfstate"
"$ROOT/scripts/validate-state.sh" "$ROOT/sandbox/terraform.tfstate"

echo "baseline tests passed"
