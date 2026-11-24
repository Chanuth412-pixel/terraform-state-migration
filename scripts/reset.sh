#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rm -rf "$ROOT/production/.terraform"
rm -rf "$ROOT/sandbox/.terraform"
mkdir -p "$ROOT/production" "$ROOT/sandbox"
find "$ROOT/production" -maxdepth 1 -type f -delete
find "$ROOT/sandbox" -maxdepth 1 -type f -delete

"$ROOT/scripts/setup.sh"
"$ROOT/scripts/emergency-change.sh"
