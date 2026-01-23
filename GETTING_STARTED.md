# Getting Started with Azurinsight

## Quick Start (Local Build)

The fastest way to get started is to build and run locally:

### Windows

```cmd
# Navigate to the project directory
cd C:\repo\_forks\Azurinsight

# Build and start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Test the server
curl http://localhost:5000/
```

### Linux/Mac

```bash
# Navigate to the project directory
cd /path/to/azurinsight

# Build and start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Test the server
curl http://localhost:5000/
```

### Using Makefile (Cross-platform)

```bash
# Build and run locally
make run

# View logs
make logs

# Check status
make status

# Stop
make stop
```

## What Happens on First Run

When you run `docker-compose up -d`:

1. **Builds the Docker image** (~2-5 minutes first time)
   - Installs Node.js dependencies
   - Compiles TypeScript to JavaScript
   - Creates optimized production image

2. **Creates a Docker volume** for SQLite database persistence

3. **Starts the container** on port 5000

4. **Server is ready** at `http://localhost:5000`

## Verifying Installation

### Check Container Status

```bash
docker-compose ps
```

Expected output:
```
NAME                  IMAGE                       STATUS
azurinsight-server    oobdev/azurinsight:latest   Up X minutes (healthy)
```

### Test the Endpoint

```bash
# Windows (PowerShell)
Invoke-WebRequest http://localhost:5000/

# Linux/Mac/Windows (curl)
curl http://localhost:5000/
```

Expected response:
```
AppInsights-ite Emulator Running
```

### Send Test Telemetry

```bash
# Windows (PowerShell)
Invoke-WebRequest -Method POST -Uri http://localhost:5000/v2.1/track `
  -ContentType "application/json" `
  -Body '{"name":"test","iKey":"test-key","data":{"baseType":"MessageData"}}'

# Linux/Mac/Windows (curl)
curl -X POST http://localhost:5000/v2.1/track \
  -H "Content-Type: application/json" \
  -d '{"name":"test","iKey":"test-key","data":{"baseType":"MessageData"}}'
```

## Common Commands

```bash
# Start (builds if needed)
docker-compose up -d

# Stop
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check health
docker inspect azurinsight-server --format='{{.State.Health.Status}}'

# Access container shell
docker-compose exec azurinsight sh

# Remove everything (including data)
docker-compose down -v
```

## Using from Docker Hub (After Publishing)

Once published, you can pull instead of building:

```bash
# Pull latest version
docker pull oobdev/azurinsight:latest

# Run with production config
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Or use specific version
docker pull oobdev/azurinsight:0.0.1
docker run -d -p 5000:5000 -v azurinsight-data:/data oobdev/azurinsight:0.0.1
```

## Integrating with Your Application

### Node.js

```javascript
const appInsights = require('applicationinsights');

appInsights.setup('<YOUR_IKEY>')
  .setInternalLogging(false, true)
  .start();

// Point to local emulator
appInsights.defaultClient.config.endpointUrl = 'http://localhost:5000/v2.1/track';

// Use as normal
appInsights.defaultClient.trackEvent({ name: 'UserLogin' });
appInsights.defaultClient.trackTrace({ message: 'App started' });
```

### Python

```python
from applicationinsights import TelemetryClient
from applicationinsights.channel import TelemetryChannel

channel = TelemetryChannel()
channel.endpoint_uri = 'http://localhost:5000/v2.1/track'

client = TelemetryClient('<YOUR_IKEY>', telemetry_channel=channel)
client.track_event('UserLogin')
client.track_trace('App started')
client.flush()
```

### .NET

```csharp
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;

var config = TelemetryConfiguration.CreateDefault();
config.ConnectionString = "InstrumentationKey=<YOUR_IKEY>;IngestionEndpoint=http://localhost:5000";

var client = new TelemetryClient(config);
client.TrackEvent("UserLogin");
client.TrackTrace("App started");
```

## Viewing Telemetry

The telemetry data is stored in SQLite and can be queried via the API:

```bash
# Get all telemetry
curl http://localhost:5000/api/telemetry

# Filter by type
curl http://localhost:5000/api/telemetry?type=Event

# Search by name
curl http://localhost:5000/api/telemetry?search=UserLogin

# Delete all telemetry
curl -X DELETE http://localhost:5000/api/telemetry
```

## Troubleshooting

### Port 5000 Already in Use

Change the port in docker-compose.yml:
```yaml
ports:
  - "8080:5000"  # Use port 8080 instead
```

Then update your application to use `http://localhost:8080`

### Build Fails

```bash
# Clean up and rebuild
docker-compose down -v
docker system prune -f
docker-compose up -d --build
```

### Container Unhealthy

```bash
# Check logs
docker-compose logs azurinsight

# Restart
docker-compose restart

# Check health
docker inspect azurinsight-server --format='{{json .State.Health}}'
```

### SQLite Database Corruption

```bash
# Backup current data
make db-backup

# Stop container
docker-compose down

# Remove volume
docker volume rm azurinsight-data

# Start fresh
docker-compose up -d
```

## Next Steps

- Read [README.docker.md](README.docker.md) for advanced configuration
- See [PUBLISHING.md](PUBLISHING.md) for publishing to Docker Hub
- Check [.github/VERSIONING.md](.github/VERSIONING.md) for version strategy
- Review [.github/GITVERSION_GUIDE.md](.github/GITVERSION_GUIDE.md) for development workflow

## Support

- GitHub Issues: https://github.com/Rahulkumar010/azurinsight/issues
- Docker Hub: https://hub.docker.com/r/oobdev/azurinsight
