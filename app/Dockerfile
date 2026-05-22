# ─────────────────────────────────────────────
# Stage 1: Build
# Use full image to install dependencies
# ─────────────────────────────────────────────
FROM nginx:1.25-alpine AS builder

WORKDIR /app
COPY . .

# ─────────────────────────────────────────────
# Stage 2: Production
# Minimal, hardened runtime image
# ─────────────────────────────────────────────
FROM nginx:1.25-alpine

# Security: create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy app from build stage
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html

# Harden nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Security: remove setuid/setgid binaries
RUN find / -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true

# Security: set correct ownership
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown appuser:appgroup /var/run/nginx.pid

# Run as non-root
USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
