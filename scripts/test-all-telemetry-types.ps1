# Test script to send all types of Application Insights telemetry
# Usage: .\test-all-telemetry-types.ps1

Write-Host "🚀 Testing all telemetry types with Azurinsight" -ForegroundColor Cyan
Write-Host ""

$uri = "http://localhost:5000/v2.1/track"
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

# 1. Trace/Message
Write-Host "1. Sending Trace/Message..." -ForegroundColor Yellow
$trace = @{
    name = "Microsoft.ApplicationInsights.Message"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service" }
    data = @{
        baseType = "MessageData"
        baseData = @{
            message = "Application started successfully"
            severityLevel = "Information"
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $trace -ContentType "application/json" | Out-Null
Write-Host "   ✓ Trace sent" -ForegroundColor Green

# 2. Event
Write-Host "2. Sending Event..." -ForegroundColor Yellow
$event = @{
    name = "Microsoft.ApplicationInsights.Event"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service"; "ai.user.id" = "user123" }
    data = @{
        baseType = "EventData"
        baseData = @{
            name = "UserLogin"
            properties = @{
                userId = "user123"
                loginMethod = "OAuth"
                successful = $true
            }
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $event -ContentType "application/json" | Out-Null
Write-Host "   ✓ Event sent" -ForegroundColor Green

# 3. Exception
Write-Host "3. Sending Exception..." -ForegroundColor Yellow
$exception = @{
    name = "Microsoft.ApplicationInsights.Exception"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service" }
    data = @{
        baseType = "ExceptionData"
        baseData = @{
            exceptions = @(
                @{
                    typeName = "System.NullReferenceException"
                    message = "Object reference not set to an instance of an object"
                    hasFullStack = $true
                    stack = "at MyApp.Service.Process() in C:\app\Service.cs:line 42"
                }
            )
            severityLevel = "Error"
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $exception -ContentType "application/json" | Out-Null
Write-Host "   ✓ Exception sent" -ForegroundColor Green

# 4. Request
Write-Host "4. Sending Request..." -ForegroundColor Yellow
$request = @{
    name = "Microsoft.ApplicationInsights.Request"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service"; "ai.operation.id" = "op123" }
    data = @{
        baseType = "RequestData"
        baseData = @{
            name = "GET /api/users"
            url = "http://localhost:5000/api/users"
            duration = "00:00:00.1234567"
            responseCode = "200"
            success = $true
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $request -ContentType "application/json" | Out-Null
Write-Host "   ✓ Request sent" -ForegroundColor Green

# 5. Dependency
Write-Host "5. Sending Dependency..." -ForegroundColor Yellow
$dependency = @{
    name = "Microsoft.ApplicationInsights.RemoteDependency"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service"; "ai.operation.id" = "op123" }
    data = @{
        baseType = "RemoteDependencyData"
        baseData = @{
            name = "SQL Query"
            type = "SQL"
            target = "mydb.database.windows.net"
            data = "SELECT * FROM Users WHERE Id = @id"
            duration = "00:00:00.0567890"
            success = $true
            resultCode = "0"
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $dependency -ContentType "application/json" | Out-Null
Write-Host "   ✓ Dependency sent" -ForegroundColor Green

# 6. Metric
Write-Host "6. Sending Metric..." -ForegroundColor Yellow
$metric = @{
    name = "Microsoft.ApplicationInsights.Metric"
    time = $timestamp
    iKey = "test-key"
    tags = @{ "ai.cloud.role" = "demo-service" }
    data = @{
        baseType = "MetricData"
        baseData = @{
            metrics = @(
                @{
                    name = "ResponseTime"
                    value = 123.45
                    count = 1
                }
            )
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $uri -Method Post -Body $metric -ContentType "application/json" | Out-Null
Write-Host "   ✓ Metric sent" -ForegroundColor Green

Write-Host ""
Write-Host "✅ All telemetry types sent successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Query results:" -ForegroundColor Cyan
$results = Invoke-RestMethod -Uri "http://localhost:5000/api/query?top=10" -Method Get
Write-Host "   Total items: $($results.value.Count)" -ForegroundColor White

Write-Host ""
Write-Host "🔍 View live telemetry:" -ForegroundColor Cyan
Write-Host "   Open watch-telemetry.html in your browser" -ForegroundColor White
Write-Host "   Or run: docker-compose logs -f" -ForegroundColor White
