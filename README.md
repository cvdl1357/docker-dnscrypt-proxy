# Docker DNSCrypt-Proxy

[![Docker Image](https://img.shields.io/badge/docker-dnscrypt--proxy-blue?logo=docker)](https://hub.docker.com/r/cvdl1357/dnscrypt-proxy)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-cvdl1357%2Fdocker--dnscrypt--proxy-green?logo=github)](https://github.com/cvdl1357/docker-dnscrypt-proxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A flexible, lightweight, multi-architecture Docker container running [DNSCrypt-Proxy](https://github.com/DNSCrypt/dnscrypt-proxy) to provide encrypted DNS resolution via **DNSCrypt v2** and **DNS-over-HTTPS (DoH)**.

---

## Features

- **Encrypted DNS**: Full support for DNSCrypt v2 and DNS-over-HTTPS (DoH) protocols.
- **DNSSEC Validation**: Ensures DNS responses are authentic and validates server signatures.
- **Modern Protocols**: Dynamic support for HTTP/3 (QUIC) to lower latency and improve reliability.
- **Multi-Architecture**: Built for `linux/amd64`, `linux/arm64` (Apple Silicon / ARM 64-bit), and `linux/arm/v7`.
- **Lightweight Baseline**: Minimal resource footprint built on Alpine Linux.
- **Highly Customizable**: Control caching, logging, DNSSEC, HTTP/3, and dynamic resolvers directly via Docker Compose environment variables without manually editing TOML files.

---

## Quick Start (Docker Compose)

The easiest way to deploy this container is using Docker Compose. The example below demonstrates an advanced configuration that utilizes a custom Cloudflare Gateway DoH endpoint alongside a public resolver (Quad9) for load-balanced redundancy.

Create a `docker-compose.yml` file:

```yaml
services:
  dnscrypt-proxy:
    # Use cvdl1357/dnscrypt-proxy:latest for Docker Hub
    # Use ghcr.io/cvdl1357/docker-dnscrypt-proxy:latest for GitHub Container Registry
    image: cvdl1357/dnscrypt-proxy:latest
    container_name: dnscrypt-proxy
    ports:
      - '5053:5053/udp'
      - '5053:5053/tcp'

    environment:
      # --- MULTIPLE RESOLVERS CONFIGURATION ---
      # SERVER_NAME: Defines the name of the static server block for your custom DoH host.
      SERVER_NAME: 'custom-doh'
      
      # SERVER_NAMES: Defines the active list of resolvers the proxy should query. 
      # Here we add Quad9 alongside your custom DoH server for redundancy.
      # CRITICAL: Strict quoting is required for valid TOML array syntax! 
      # You must wrap single quotes inside double quotes.
      SERVER_NAMES: "'custom-doh', 'quad9-dnscrypt-ip4-filter-pri'"

      # --- LISTENER & CACHING ---
      # 0.0.0.0 allows access from outside the container (required for Docker bridge networks)
      LISTEN_ADDRESSES: "['0.0.0.0:5053']"
      
      # Set to 'false' if you are using Pi-hole downstream to avoid double-caching
      CACHE_ENABLED: 'false'

      # --- SECURITY & PROTOCOL ---
      REQUIRE_DNSSEC: 'true'
      HTTP3_ENABLED: 'true'

      # --- LOGGING ---
      # 0-6 (0=fatal, 1=error, 2=warn, 3=notice, 4=info, 5=debug, 6=trace)
      LOG_LEVEL: 2

      # --- CUSTOM DOH PROVIDER CONFIGURATION ---
      # This generates the SDNS stamp for 'custom-doh' defined above.
      # Format for DOH_HOST is vhost.SNI
      DOH_HOST: 'family.cloudflare-gateway.com'
      DOH_PATH: '/dns-query'

      # Custom IPs used to resolve DOH_HOST directly during startup without public DNS lookups
      BOOTSTRAP_RESOLVERS: '1.1.1.1:53,1.0.0.1:53'
      NETPROBE_ADDRESS: '1.1.1.1:53'

    volumes:
      # Optional: Mount custom local CA certificates into the container (Read-Only)
      - './certs:/etc/ssl/certs/custom:ro'

    restart: unless-stopped
```

Run the container:

```bash
docker compose up -d
```

---

## Environment Variables Guide

### Core Configuration

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SERVER_NAME` | `custom-doh` | The internal identifier for your custom DoH configuration block. |
| `SERVER_NAMES` | `'$SERVER_NAME'` | The active list of resolvers to query. If defining multiple resolvers, **they must be double-quoted with inner single quotes** (e.g., `"'custom-doh', 'cloudflare'"`). If omitted, defaults to the single `SERVER_NAME`. |
| `LISTEN_ADDRESSES`| `['0.0.0.0:5053']` | The IP and port the proxy binds to. Use `['0.0.0.0:5053']` for Docker bridge mode, or `['127.0.0.1:5053']` for `network_mode: host`. |

### Performance & Security

| Variable | Default | Description |
| :--- | :--- | :--- |
| `CACHE_ENABLED` | `true` | Enables internal DNS caching. It is highly recommended to set this to `false` if you run Pi-hole or AdGuard Home downstream to avoid double-caching. |
| `REQUIRE_DNSSEC` | `false` | Forces the selection of servers that support DNSSEC. Set to `true` if your downstream DNS server strictly validates DNSSEC. |
| `HTTP3_ENABLED` | `false` | Enables HTTP/3 (QUIC) for DoH queries, significantly lowering latency and improving reliability over TCP connections. |
| `LOG_LEVEL` | `2` | Adjusts logging verbosity. Default is 2 (warnings/errors). Set to `5` or `6` for detailed troubleshooting. |

---

## Verification

Verify that DNSCrypt-Proxy is actively resolving encrypted queries on the configured port (default `5053`):

```bash
# Query via local port 5053
dig @127.0.0.1 -p 5053 example.com

# Verify resolver status and loaded certificates via DNSCrypt debug endpoint
dig @127.0.0.1 -p 5053 resolver-check.dnscrypt.info
```

---

## Documentation & Links

* **Source Code:** [GitHub Repository](https://github.com/cvdl1357/docker-dnscrypt-proxy)
* **Docker Hub:** [cvdl1357/dnscrypt-proxy](https://hub.docker.com/r/cvdl1357/dnscrypt-proxy)
* **Security Policy:** [SECURITY.md](https://github.com/cvdl1357/docker-dnscrypt-proxy/blob/main/SECURITY.md)
* **License:** [MIT License](https://github.com/cvdl1357/docker-dnscrypt-proxy/blob/main/LICENSE)
