#!/bin/sh
set -e

# 0. Import custom Root CA certificates if mounted
CUSTOM_CERTS_DIR="/etc/ssl/certs/custom"
SYSTEM_CERTS_DIR="/usr/local/share/ca-certificates"

if [ -d "$CUSTOM_CERTS_DIR" ] && [ "$(ls -A $CUSTOM_CERTS_DIR 2>/dev/null)" ]; then
  echo "[entrypoint] Found custom certificates in $CUSTOM_CERTS_DIR. Installing..."

  # Copy certificates from RO mount to system directory
  cp -f "$CUSTOM_CERTS_DIR"/* "$SYSTEM_CERTS_DIR"/ 2>/dev/null || true

  # Update OS certificate store (Works for Alpine/Debian base images)
  if command -v update-ca-certificates >/dev/null 2>&1; then
    update-ca-certificates
  fi
fi

# 1. Defaults for runtime configuration
export SERVER_NAME="${SERVER_NAME:-custom-doh}"
export FORMATTED_SERVER_NAMES="'${SERVER_NAME}'"
export NETPROBE_ADDRESS="${NETPROBE_ADDRESS:-1.1.1.1:53}"

# 2. Format comma-separated BOOTSTRAP_RESOLVERS into TOML string list syntax: '1.1.1.1:53', '8.8.8.8:53'
if [ -n "$BOOTSTRAP_RESOLVERS" ]; then
  export FORMATTED_BOOTSTRAP=$(echo "$BOOTSTRAP_RESOLVERS" | sed "s/[^,][^,]*/'&'/g" | sed 's/,/, /g')
else
  export FORMATTED_BOOTSTRAP="'1.1.1.1:53', '9.9.9.9:53'"
fi

# 3. Generate SDNS Stamp if CUSTOM_STAMP is not provided
if [ -z "$CUSTOM_STAMP" ]; then
  if [ -z "$DOH_HOST" ]; then
    echo "[entrypoint] ERROR: DOH_HOST environment variable is missing!"
    exit 1
  fi

  echo "[entrypoint] Generating DoH SDNS stamp for host: $DOH_HOST..."

  export GENERATED_STAMP=$(python3 -c "
import base64, os

host = os.environ.get('DOH_HOST', '').strip()
path = os.environ.get('DOH_PATH', '/dns-query').strip()

proto = b'\x02'
props = b'\x00\x00\x00\x00\x00\x00\x00\x00'
ip_field = b'\x00'
hashes_field = b'\x00'

host_bytes = host.encode('utf-8')
host_field = bytes([len(host_bytes)]) + host_bytes

path_bytes = path.encode('utf-8')
path_field = bytes([len(path_bytes)]) + path_bytes

raw_stamp = proto + props + ip_field + hashes_field + host_field + path_field
print('sdns://' + base64.urlsafe_b64encode(raw_stamp).decode('utf-8').rstrip('='))
")
  export FINAL_STAMP="$GENERATED_STAMP"
else
  echo "[entrypoint] Using provided CUSTOM_STAMP..."
  export FINAL_STAMP="$CUSTOM_STAMP"
fi

# 4. Substitute environment variables into dnscrypt-proxy.toml template
envsubst '$FORMATTED_SERVER_NAMES $SERVER_NAME $NETPROBE_ADDRESS $FORMATTED_BOOTSTRAP $FINAL_STAMP' \
  < /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template \
  > /etc/dnscrypt-proxy/dnscrypt-proxy.toml

echo "[entrypoint] Starting dnscrypt-proxy using server configuration: ${SERVER_NAME}..."

# 5. Hand off process execution to dnscrypt-proxy
exec dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
