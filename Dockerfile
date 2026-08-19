# Stage 1: Build binary using official Go toolchain
FROM golang:alpine AS builder

RUN apk add --no-cache git

# Clone upstream repository and build binary
RUN git clone --depth 1 https://github.com/DNSCrypt/dnscrypt-proxy.git /src
WORKDIR /src/dnscrypt-proxy
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /go/bin/dnscrypt-proxy

# Stage 2: Minimal, secure runtime
FROM alpine:latest

RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        gettext \
        python3

WORKDIR /etc/dnscrypt-proxy

# Copy compiled binary from builder stage
COPY --from=builder /go/bin/dnscrypt-proxy /usr/bin/dnscrypt-proxy
COPY dnscrypt-proxy.toml.template /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 5053/tcp 5053/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
