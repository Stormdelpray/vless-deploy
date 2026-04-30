# VLESS multi-region deploy (Render + Railway)

VLESS (`xray-core`) over WebSocket + TLS (TLS terminated by the PaaS platform).
The same Docker image is deployed to multiple regions on Render and Railway;
each deployment becomes a VLESS endpoint in a different country.

**Why WebSocket + TLS and not Reality / raw TCP?**
Render and Railway only expose an HTTPS load balancer — raw TCP is not
available on their free tiers. VLESS-over-WebSocket looks like ordinary HTTPS
traffic to the platform load balancer, so it passes through cleanly.

## Layout

- `Dockerfile` — multi-stage build, pulls `xray-core` + geoip/geosite assets.
- `config.json.tmpl` — Xray config with `${PORT}`, `${VLESS_UUID}`, `${WS_PATH}` placeholders.
- `entrypoint.sh` — renders the config with `envsubst` and starts Xray.
- `render.yaml` — Render Blueprint describing 4 regional services.
- `railway.json` — Railway build/deploy config.

## Env vars

| Var | Description | Default |
| --- | ----------- | ------- |
| `PORT` | Listen port (injected by Render/Railway) | 8080 |
| `VLESS_UUID` | Client UUID | *required* |
| `WS_PATH` | WebSocket path, must start with `/` | `/ws` |

## Client config

VLESS link format:

```
vless://<UUID>@<host>:443?type=ws&security=tls&host=<host>&sni=<host>&path=<url-encoded-path>&encryption=none#<label>
```

Paste into v2rayN / v2rayNG / Streisand / Hiddify / NekoBox.

## Redeploy

Push to `main` — both Render and Railway rebuild automatically.

## Regenerate UUID

```sh
# 1. Generate a new UUID
python3 -c "import uuid; print(uuid.uuid4())"
# 2. Update VLESS_UUID env var on every Render service and every Railway service
# 3. Services redeploy automatically; update client links accordingly
```
