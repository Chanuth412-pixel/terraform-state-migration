#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="${1:-$ROOT/production/terraform.tfstate}"

python3 - "$STATE" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    state = json.load(handle)

resources = {}
for resource in state.get("resources", []):
    if resource.get("mode") == "managed" and resource.get("type") == "terraform_data":
        for instance in resource.get("instances", []):
            attrs = instance.get("attributes", {})
            data = attrs.get("input") or {}
            if isinstance(data, dict):
                data = data.get("value") or data
            resource_id = data.get("id")
            if resource_id:
                resources[resource_id] = {
                    "address": resource["module"] + "." + resource["name"] if "module" in resource else resource["type"] + "." + resource["name"],
                    "data": data,
                }

expected = {
    "vnet-prod-001",
    "subnet-public-prod-001",
    "subnet-private-prod-001",
    "nsg-platform-prod-001",
    "app-orders-prod-001",
    "lb-orders-prod-001",
    "db-orders-prod-001",
    "db-backup-orders-prod-001",
}
missing = expected - resources.keys()
if missing:
    raise SystemExit("missing resources: " + ", ".join(sorted(missing)))

database = resources["db-orders-prod-001"]["data"]
app = resources["app-orders-prod-001"]["data"]
lb = resources["lb-orders-prod-001"]["data"]
backup = resources["db-backup-orders-prod-001"]["data"]

if app["database_endpoint"] != database["endpoint"]:
    raise SystemExit("application database_endpoint does not match database endpoint")
if app["database_id"] != database["id"]:
    raise SystemExit("application database_id does not match database identity")
if app["subnet_id"] != resources["subnet-private-prod-001"]["data"]["id"]:
    raise SystemExit("application is not attached to the private subnet")
if lb["app_server_id"] != app["id"]:
    raise SystemExit("load balancer does not reference the application")
if backup["database_id"] != database["id"]:
    raise SystemExit("backup does not reference the database")
if database["subnet_id"] != resources["subnet-private-prod-001"]["data"]["id"]:
    raise SystemExit("database is not attached to the private subnet")

print("validated " + str(len(resources)) + " synthetic resources in " + path)
PY