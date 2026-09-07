# Stage 1: Build binary using the latest patched Go toolchain
FROM golang:alpine AS builder

RUN apk add --no-cache git

# Force downloading updated Go modules
WORKDIR /src
RUN git clone --depth 1 https://github.com/DNSCrypt/dnscrypt-proxy.git /src
WORKDIR /src/dnscrypt-proxy

# Update dependencies to pull patched submodules
RUN go get -u ./... && go mod tidy
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /go/bin/dnscrypt-proxy

# Stage 2: Minimal, secure runtime
FROM alpine:latest

RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        gettext \
        python3

WORKDIR /etc/dnscrypt-proxy

COPY --from=builder /go/bin/dnscrypt-proxy /usr/bin/dnscrypt-proxy
COPY dnscrypt-proxy.toml.template /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 5053/tcp 5053/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
