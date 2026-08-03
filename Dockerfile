# Use a lightweight Alpine base
FROM alpine:latest

# Install dnscrypt-proxy, ca-certificates, gettext (for envsubst), and python3 (for stamp generation)
RUN apk add --no-cache \
    dnscrypt-proxy \
    ca-certificates \
    gettext \
    python3

# Create directory for configurations
WORKDIR /etc/dnscrypt-proxy

# Copy configuration template and entrypoint script
COPY dnscrypt-proxy.toml.template /etc/dnscrypt-proxy/dnscrypt-proxy.toml.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure entrypoint script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose DNS port 5053 (both UDP and TCP)
EXPOSE 5053/tcp 5053/udp

# Run via entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
