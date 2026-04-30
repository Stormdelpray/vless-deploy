#!/usr/bin/env bash
set -euo pipefail

: "${PORT:=8080}"
: "${VLESS_UUID:?VLESS_UUID env var is required}"
: "${WS_PATH:=/ws}"

export PORT VLESS_UUID WS_PATH

envsubst < /etc/xray/config.json.tmpl > /etc/xray/config.json

echo "[entrypoint] Starting Xray on port $PORT, ws path=$WS_PATH"
exec /usr/local/bin/xray run -c /etc/xray/config.json
