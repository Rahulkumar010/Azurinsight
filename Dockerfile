# Multi-stage build for Azurinsight Server
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./
COPY packages/server/package.json ./packages/server/

# Install dependencies
RUN npm ci --workspaces=false && \
    cd packages/server && npm ci

# Copy source code
COPY packages/server ./packages/server

# Build the server
RUN cd packages/server && npm run build

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

# Install production dependencies only
COPY package.json package-lock.json* ./
COPY packages/server/package.json ./packages/server/

RUN npm ci --workspaces=false --only=production && \
    cd packages/server && npm ci --only=production

# Copy built files from builder
COPY --from=builder /app/packages/server/dist ./packages/server/dist

# Create directory for SQLite database
RUN mkdir -p /data

# Set environment variables
ENV PORT=5000
ENV DB_PATH=/data/telemetry.sqlite
ENV NODE_ENV=production

# Expose the server port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the server
CMD ["node", "packages/server/dist/index.js"]
