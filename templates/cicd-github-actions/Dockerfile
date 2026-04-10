# Production-ready Docker image for CI/CD template
FROM nginx:alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user and group
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy application files directly
COPY --chown=appuser:appgroup app /usr/share/nginx/html

# Set permissions for nginx and create pid directory in same layer as user creation
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    chown -R appuser:appgroup /var/run && \
    chown -R appuser:appgroup /tmp && \
    mkdir -p /var/run/nginx && \
    chown -R appuser:appgroup /var/run/nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
