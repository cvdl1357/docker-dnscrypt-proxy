# Use a lightweight Alpine base
FROM alpine:latest

# Upgrade base packages and install required dependencies
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        dnscrypt-proxy \
        ca-certificates \
        gettext \
        python3

# Create directory for configurations
WORKDIR /etc/dnscrypt-proxy

# Copy configuration template and entrypoint script with executable permissions
COPY dnscrypt-proxy.toml.template /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Expose DNS port 5053 (both UDP and TCP)
EXPOSE 5053/tcp 5053/udp

# Run via entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
