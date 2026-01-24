# Simple PowerShell WebSocket client to stream telemetry from Azurinsight
# Usage: .\watch-stream.ps1

Write-Host "Connecting to Azurinsight WebSocket..." -ForegroundColor Cyan

$uri = "ws://localhost:5000"
$itemCount = 0

try {
    # Create WebSocket client
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $ct = New-Object System.Threading.CancellationToken

    # Connect
    $connectTask = $ws.ConnectAsync($uri, $ct)
    while (-not $connectTask.IsCompleted) {
        Start-Sleep -Milliseconds 100
    }

    if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        Write-Host "✓ Connected to Azurinsight WebSocket" -ForegroundColor Green
        Write-Host "Listening for telemetry events... (Ctrl+C to exit)" -ForegroundColor Gray
        Write-Host ""

        # Receive loop
        $buffer = New-Object Byte[] 8192
        $segment = New-Object System.ArraySegment[Byte] -ArgumentList @(,$buffer)

        while ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
            $receiveTask = $ws.ReceiveAsync($segment, $ct)
            while (-not $receiveTask.IsCompleted) {
                Start-Sleep -Milliseconds 10
            }

            $result = $receiveTask.Result

            if ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Text) {
                $message = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count)

                try {
                    $item = $message | ConvertFrom-Json
                    $itemCount++

                    $type = ($item.data.baseType -replace 'Data', '') ?? 'unknown'
                    $timestamp = (Get-Date $item.time).ToString('HH:mm:ss')
                    $msg = $item.data.baseData.message ?? $item.data.baseData.name ?? ''
                    $name = $item.name ?? 'Unnamed'

                    $typeColor = switch ($type) {
                        'Message' { 'Cyan' }
                        'Event' { 'Green' }
                        'Exception' { 'Red' }
                        'Request' { 'Yellow' }
                        'Dependency' { 'Magenta' }
                        'Metric' { 'Blue' }
                        default { 'White' }
                    }

                    Write-Host "[$timestamp] " -ForegroundColor Gray -NoNewline
                    Write-Host $type.ToUpper() -ForegroundColor $typeColor
                    Write-Host "  $name" -ForegroundColor White
                    if ($msg) {
                        Write-Host "  $msg" -ForegroundColor Gray
                    }

                    # Show tags
                    if ($item.tags) {
                        $tags = ($item.tags.PSObject.Properties | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ', '
                        Write-Host "  $tags" -ForegroundColor DarkGray
                    }

                    Write-Host ""

                } catch {
                    Write-Host "Error parsing telemetry: $_" -ForegroundColor Red
                }
            }
            elseif ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
                break
            }
        }
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Make sure Azurinsight is running: docker-compose ps" -ForegroundColor Yellow
}
finally {
    if ($ws) {
        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Closing", $ct) | Out-Null
        $ws.Dispose()
    }

    Write-Host ""
    Write-Host "✗ Disconnected from Azurinsight" -ForegroundColor Yellow
    Write-Host "Total events received: $itemCount" -ForegroundColor Gray
}
