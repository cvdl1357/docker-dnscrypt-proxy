# dnscrypt-proxy

A flexible, lightweight multi-architecture Docker container for **dnscrypt-proxy** built on Alpine Linux. Supports `amd64`, `arm64`, and `arm/v7` platforms.

---

## Quick Start

### 1. Using Docker Compose (Recommended)

Create a `docker-compose.yml` file:

```yaml
services:
  dnscrypt-proxy:
    image: cvdl1357/dnscrypt-proxy:latest
    container_name: dnscrypt-proxy
    restart: unless-stopped
    ports:
      - "5053:5053/udp"
      - "5053:5053/tcp"
    environment:
      - TZ=UTC
    volumes:
      - ./config:/config
```

Run the container:

```bash
docker compose up -d
```

---

### 2. Using Docker CLI

```bash
docker run -d \
  --name=dnscrypt-proxy \
  --restart=unless-stopped \
  -p 5053:5053/udp \
  -p 5053:5053/tcp \
  -e TZ=UTC \
  -v $(pwd)/config:/config \
  cvdl1357/dnscrypt-proxy:latest
```

---

## Features & Configuration

* **Default Port:** `5053` (TCP/UDP)
* **Base Image:** Alpine Linux
* **Supported Architectures:** `linux/amd64`, `linux/arm64`, `linux/arm/v7`

Configuration settings can be modified by editing `dnscrypt-proxy.toml` inside your mounted volume directory.

---

## Documentation & Links

* **Source Code:** [GitHub Repository](https://github.com/cvdl1357/docker-dnscrypt-proxy)
* **Security Policy:** [SECURITY.md](https://github.com/cvdl1357/docker-dnscrypt-proxy/blob/main/SECURITY.md)
* **License:** [MIT License](https://github.com/cvdl1357/docker-dnscrypt-proxy/blob/main/LICENSE)
