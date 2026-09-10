#!/usr/bin/env bash
# civicnet node healthcheck — RPC reachable + synced.
set -euo pipefail
RPC_USER="${RPC_USER:-coin}"
RPC_PORT="${RPC_PORT:-9332}"
RPC_PASS="${RPC_PASS:-}"

info="$(curl -sS --user "$RPC_USER:$RPC_PASS" \
  --data-binary '{"jsonrpc":"1.0","id":"hc","method":"getblockchaininfo","params":[]}' \
  -H 'content-type: text/plain;' \
  "http://127.0.0.1:$RPC_PORT/" 2>/dev/null || true)"

if [ -z "$info" ] || echo "$info" | grep -q '"error"'; then
  echo "ERROR: RPC unreachable." >&2; exit 1
fi
verification="$(echo "$info" | sed -n 's/.*"verificationprogress":\([0-9.]*\).*/\1/p')"
awk -v v="$verification" 'BEGIN{exit !(v>=0.9999)}' || {
  echo "ERROR: not fully synced (verificationprogress=$verification)." >&2; exit 1
}
echo "OK sync=$verification"
