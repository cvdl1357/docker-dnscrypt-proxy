# Stage 1: Build binary using the latest patched Go toolchain
FROM golang:alpine AS builder

RUN apk add --no-cache git
RUN CGO_ENABLED=0 go install -ldflags="-s -w" github.com/DNSCrypt/dnscrypt-proxy/v2/dnscrypt-proxy@latest

# Stage 2: Minimal, secure runtime
FROM alpine:latest

RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        gettext

WORKDIR /etc/dnscrypt-proxy

# Copy compiled binary from builder
COPY --from=builder /go/bin/dnscrypt-proxy /usr/bin/dnscrypt-proxy
COPY dnscrypt-proxy.toml.template /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 5053/tcp 5053/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
