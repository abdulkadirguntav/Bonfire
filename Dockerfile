# ==============================================================================
# Multi-Stage Dockerfile for Bonfire Flutter Web Application
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Build Flutter Web Artifacts
# ------------------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION="3.29.0"
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

# Install minimal build prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter stable SDK
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_HOME}

# Pre-download Flutter Web binaries and verify
RUN flutter config --enable-web && flutter precache --web

# Set workspace
WORKDIR /app

# Copy dependency manifests first for layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy full application source
COPY . .

# Build production Web bundle
RUN flutter build web --release

# ------------------------------------------------------------------------------
# Stage 2: Production Nginx Server
# ------------------------------------------------------------------------------
FROM nginx:alpine-slim AS production

# Install curl for container health check
RUN apk add --no-cache curl

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Web bundle from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose standard HTTP port
EXPOSE 80

# Health Check verification
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/healthz || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
