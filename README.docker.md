# Azurinsight - Azure Application Insights Local Emulator

[![Docker Hub](https://img.shields.io/docker/v/oobdev/azurinsight?label=Docker%20Hub)](https://hub.docker.com/r/oobdev/azurinsight)
[![Docker Pulls](https://img.shields.io/docker/pulls/oobdev/azurinsight)](https://hub.docker.com/r/oobdev/azurinsight)
[![Docker Image Size](https://img.shields.io/docker/image-size/oobdev/azurinsight/latest)](https://hub.docker.com/r/oobdev/azurinsight)

Run Azure Application Insights telemetry ingestion locally without cloud dependencies. Perfect for development, testing, and offline scenarios.

## Features

- 🚀 **Full Application Insights API compatibility** - Works with all official SDKs (Node.js, Python, .NET, Java)
- 💾 **SQLite storage** - Persistent local telemetry data
- 🔄 **Real-time WebSocket streaming** - Live telemetry updates
- 🐳 **Multi-platform support** - linux/amd64 and linux/arm64
- 📊 **Query API** - Search, filter, and manage telemetry
- ⚡ **Lightweight** - ~150MB Alpine-based image

## Quick Start

### Using Docker Compose (Recommended)

#### Option 1: Build Locally (Default)

The default configuration builds the image from source:

1. Start the container:
```bash
docker-compose up -d
```

2. View logs:
```bash
docker-compose logs -f
```

3. Stop the container:
```bash
docker-compose down
```

4. Stop and remove data:
```bash
docker-compose down -v
```

#### Option 2: Pull from Docker Hub (Production)

Once the image is published to Docker Hub, you can pull it instead of building:

```bash
# Use production override
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Or pull manually first
docker pull oobdev/azurinsight:latest
docker-compose up -d
```

### Using Docker CLI

#### Build Locally

1. Build the image:
```bash
docker build -t oobdev/azurinsight:latest .
```

2. Run the container:
```bash
docker run -d \
  --name azurinsight-server \
  -p 5000:5000 \
  -v azurinsight-data:/data \
  oobdev/azurinsight:latest
```

#### Pull from Docker Hub

1. Pull and run:
```bash
docker pull oobdev/azurinsight:latest
docker run -d \
  --name azurinsight-server \
  -p 5000:5000 \
  -v azurinsight-data:/data \
  oobdev/azurinsight:latest
```

2. View logs:
```bash
docker logs -f azurinsight-server
```

4. Stop and remove:
```bash
docker stop azurinsight-server
docker rm azurinsight-server
```

## Available Tags

- `latest` - Latest stable release
- `1.0.0`, `1.0`, `1` - Semantic versioning
- `main` - Latest development build

```bash
# Pull specific version
docker pull oobdev/azurinsight:1.0.0

# Pull latest
docker pull oobdev/azurinsight:latest
```

## Configuration

### Environment Variables

- `PORT` - Server port (default: 5000)
- `DB_PATH` - SQLite database path (default: /data/telemetry.sqlite)
- `NODE_ENV` - Node environment (default: production)

### Custom Configuration Example

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  azurinsight:
    environment:
      - PORT=8080
    ports:
      - "8080:8080"
```

## Accessing the Service

Once running, the server will be available at:
- Telemetry ingestion: `http://localhost:5000/v2.1/track`
- Query API: `http://localhost:5000/api/telemetry`
- WebSocket: `ws://localhost:5000`
- Health check: `http://localhost:5000/`

## Data Persistence

The SQLite database is stored in a Docker volume named `azurinsight-data`. This ensures your telemetry data persists across container restarts.

To backup the database:
```bash
docker run --rm -v azurinsight-data:/data -v $(pwd):/backup alpine tar czf /backup/azurinsight-backup.tar.gz -C /data .
```

To restore:
```bash
docker run --rm -v azurinsight-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/azurinsight-backup.tar.gz"
```

## Integration with Application Insights SDKs

Configure your Application Insights SDK to point to the Docker container:

### Node.js
```javascript
const appInsights = require('applicationinsights');
appInsights.setup('<YOUR_IKEY>')
  .setInternalLogging(false, true)
  .start();

appInsights.defaultClient.config.endpointUrl = 'http://localhost:5000/v2.1/track';
```

### Python
```python
from applicationinsights import TelemetryClient
from applicationinsights.channel import TelemetryChannel

channel = TelemetryChannel()
channel.endpoint_uri = 'http://localhost:5000/v2.1/track'
tc = TelemetryClient('<YOUR_IKEY>', telemetry_channel=channel)
```

### .NET
```csharp
var config = TelemetryConfiguration.CreateDefault();
config.ConnectionString = "InstrumentationKey=<YOUR_IKEY>;IngestionEndpoint=http://localhost:5000";
var client = new TelemetryClient(config);
```

## Production Deployment

For production deployments, consider:

1. **Reverse Proxy**: Use nginx or traefik for SSL/TLS termination
2. **Resource Limits**: Add memory and CPU limits in docker-compose.yml
3. **Monitoring**: Use Docker health checks and monitoring tools
4. **Backup**: Schedule regular database backups
5. **Networking**: Use Docker networks to isolate services

Example with resource limits:
```yaml
services:
  azurinsight:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Troubleshooting

### Check container status
```bash
docker-compose ps
```

### View real-time logs
```bash
docker-compose logs -f azurinsight
```

### Access container shell
```bash
docker-compose exec azurinsight sh
```

### Check database
```bash
docker-compose exec azurinsight ls -lh /data/
```

### Port conflicts
If port 5000 is already in use, change the host port in docker-compose.yml:
```yaml
ports:
  - "8080:5000"  # Maps host:8080 to container:5000
```
