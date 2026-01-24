# Azurinsight Test Scripts

This folder contains various scripts to test and interact with Azurinsight.

## Test Telemetry Scripts

Send "Hello World" test telemetry to verify Azurinsight is working:

### Windows (Batch)
```cmd
scripts\test-telemetry.bat
```

### Windows (PowerShell)
```powershell
scripts\test-telemetry.ps1
```

### Linux/Mac (Bash)
```bash
./scripts/test-telemetry.sh
```

## All Telemetry Types

Send examples of all Application Insights telemetry types (Message, Event, Exception, Request, Dependency, Metric):

```powershell
scripts\test-all-telemetry-types.ps1
```

## WebSocket Streaming Clients

Live stream telemetry events as they arrive:

### Node.js
```bash
node scripts/watch-stream.js
```

### Python
```bash
# Install dependency first: pip install websocket-client
python scripts/watch-stream.py
```

### PowerShell
```powershell
scripts\watch-stream.ps1
```

## Web UI Viewer

Open the standalone HTML viewer (also available at http://localhost:5000/ when server is running):

```bash
# Windows
start scripts\watch-telemetry.html

# Or just double-click the file
```

## Prerequisites

- **Azurinsight server must be running**: `docker-compose up -d`
- **Server URL**: Default is `http://localhost:5000`

## Usage Tips

1. **Start the server first**:
   ```bash
   docker-compose up -d
   ```

2. **Run a test script** to send telemetry

3. **View telemetry** in one of these ways:
   - Web browser: http://localhost:5000/
   - Docker logs: `docker-compose logs -f`
   - WebSocket client: `node scripts/watch-stream.js`

4. **Query telemetry** via API:
   ```bash
   curl http://localhost:5000/api/query
   ```

## Troubleshooting

### Connection Refused

```bash
# Check if server is running
docker-compose ps

# Restart if needed
docker-compose restart
```

### Port 5000 Already in Use

Edit `docker-compose.yml` to change the port:
```yaml
ports:
  - "8080:5000"  # Use port 8080 instead
```

Then update test scripts to use port 8080.

### WebSocket Client Dependencies

**Node.js**: No extra dependencies needed (uses built-in `ws` from server's node_modules)

**Python**: Install websocket-client:
```bash
pip install websocket-client
```

**PowerShell**: No dependencies needed (uses built-in .NET WebSocket client)
