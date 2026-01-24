# Test script to send Hello World telemetry to Azurinsight
# Usage: .\test-telemetry.ps1

Write-Host "Sending Hello World telemetry to Azurinsight..." -ForegroundColor Cyan

$uri = "http://localhost:5000/v2.1/track"
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

$body = @{
    name = "Microsoft.ApplicationInsights.Message"
    time = $timestamp
    iKey = "test-key"
    tags = @{
        "ai.cloud.role" = "test-script"
        "ai.cloud.roleInstance" = "windows-powershell"
        "ai.device.os" = "Windows"
    }
    data = @{
        baseType = "MessageData"
        baseData = @{
            message = "Hello World from PowerShell!"
            severityLevel = "Information"
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Gray

    Write-Host "`nQuerying telemetry..." -ForegroundColor Cyan
    $telemetry = Invoke-RestMethod -Uri "http://localhost:5000/api/query?top=5" -Method Get
    Write-Host "Recent telemetry items: $($telemetry.value.Count)" -ForegroundColor Yellow

    if ($telemetry.value.Count -gt 0) {
        Write-Host "`nLatest message:" -ForegroundColor Cyan
        $latest = $telemetry.value[0]
        $data = $latest.data | ConvertFrom-Json
        Write-Host "  Time: $($latest.time)" -ForegroundColor Gray
        Write-Host "  Type: $($latest.itemType)" -ForegroundColor Gray
        Write-Host "  Message: $($data.baseData.message)" -ForegroundColor White
    }
}
catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the Azurinsight server is running: docker-compose ps" -ForegroundColor Yellow
}
