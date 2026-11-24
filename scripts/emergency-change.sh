#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCTION="$ROOT/production"

cd "$PRODUCTION"
terraform apply -auto-approve -input=false -var="database_capacity_gb=200"

python3 - "$PRODUCTION/terraform.tfstate" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    state = json.load(handle)

for resource in state.get("resources", []):
    if resource.get("type") != "terraform_data" or resource.get("name") != "database":
        continue
    for instance in resource.get("instances", []):
        data = (instance.get("attributes") or {}).get("input") or {}
        if isinstance(data, dict):
            data = data.get("value") or data
        if data.get("capacity_gb") == 200:
            print("verified emergency database capacity: 200 GB")
            raise SystemExit(0)

raise SystemExit("database capacity emergency change was not found")
PY
