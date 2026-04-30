FROM alpine:3.20 AS build

ARG XRAY_VERSION=1.8.23
RUN apk add --no-cache curl unzip ca-certificates \
 && ARCH=$(uname -m) \
 && case "$ARCH" in \
      x86_64)  XARCH=64 ;; \
      aarch64) XARCH=arm64-v8a ;; \
      armv7l)  XARCH=arm32-v7a ;; \
      *) echo "unsupported arch $ARCH"; exit 1 ;; \
    esac \
 && curl -fL -o /tmp/xray.zip \
      "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-${XARCH}.zip" \
 && mkdir -p /out \
 && unzip -o /tmp/xray.zip -d /out \
 && chmod +x /out/xray \
 && curl -fL -o /out/geoip.dat \
      "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" \
 && curl -fL -o /out/geosite.dat \
      "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"

FROM alpine:3.20
RUN apk add --no-cache ca-certificates gettext bash
COPY --from=build /out/xray /usr/local/bin/xray
COPY --from=build /out/geoip.dat /usr/local/share/xray/geoip.dat
COPY --from=build /out/geosite.dat /usr/local/share/xray/geosite.dat
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray
COPY config.json.tmpl /etc/xray/config.json.tmpl
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Render/Railway inject $PORT. Default to 8080 for local runs.
ENV PORT=8080 \
    VLESS_UUID=00000000-0000-0000-0000-000000000000 \
    WS_PATH=/ws

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
