# Docker DNSCrypt-Proxy

[![Docker Image](https://img.shields.io/badge/docker-dnscrypt--proxy-blue?logo=docker)](https://github.com/cvdl1357/docker-dnscrypt-proxy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight, multi-architecture Docker container running [DNSCrypt-Proxy](https://github.com/DNSCrypt/dnscrypt-proxy) to provide encrypted DNS resolution via **DNSCrypt v2** and **DNS-over-HTTPS (DoH)**.

---

## Features

- **Encrypted DNS**: Full support for DNSCrypt v2 and DNS-over-HTTPS (DoH) protocols.
- **DNSSEC Validation**: Ensures DNS responses are authentic and authenticates server signatures.
- **Multi-Architecture**: Built for `linux/amd64`, `linux/arm64` (Apple Silicon / ARM 64-bit), and `linux/arm/v7`.
- **Lightweight Baseline**: Minimal resource footprint built on Alpine Linux.
- **Customizable**: Dynamic environment variable configuration for DoH providers, bootstrap resolvers, and custom CA certificate mounting.

---

## Quick Start

### 1. Using Docker Compose (Recommended)

Create a `docker-compose.yml` file:

```yaml
services:
  dnscrypt-proxy:
    image: ghcr.io/cvdl1357/docker-dnscrypt-proxy:latest
    container_name: dnscrypt-proxy
    ports:
      - '5053:5053/udp'
      - '5053:5053/tcp'

    environment:
      SERVER_NAME: 'custom-doh'

      # DoH Provider Configuration (Format for DOH_HOST is vhost.SNI)
      DOH_HOST: 'family.cloudflare-gateway.com'
      DOH_PATH: '/dns-query'

      # Bootstrap resolvers used to resolve DOH_HOST directly without public DNS lookups
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

## Verification

Verify that DNSCrypt-Proxy is actively resolving encrypted queries on port 5053:

```bash
# Query via local port 5053
dig @127.0.0.1 -p 5053 example.com

# Verify resolver status via DNSCrypt debug endpoint
dig @127.0.0.1 -p 5053 resolver-check.dnscrypt.info
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

