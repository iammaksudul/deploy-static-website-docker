# Multi-stage Docker build for static website
FROM nginx:alpine AS base

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx

# Build stage
FROM base AS builder

# Copy source files
COPY src/ /tmp/src/

# Optimize and minify files (in production, you might use build tools)
RUN mkdir -p /tmp/dist && \
    cp -r /tmp/src/* /tmp/dist/ && \
    # Remove comments and minify CSS (basic optimization)
    sed -i '/^[[:space:]]*\/\*/,/\*\//d' /tmp/dist/styles.css && \
    sed -i '/^[[:space:]]*$/d' /tmp/dist/styles.css

# Production stage
FROM base AS production

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy optimized website files
COPY --from=builder --chown=nginx:nginx /tmp/dist/ /usr/share/nginx/html/

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
