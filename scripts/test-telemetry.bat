@echo off
REM Test script to send Hello World telemetry to Azurinsight
REM Usage: test-telemetry.bat

echo Sending Hello World telemetry to Azurinsight...

curl -X POST http://localhost:5000/v2.1/track ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Microsoft.ApplicationInsights.Message\",\"time\":\"%date:~-4%-%date:~4,2%-%date:~7,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%.000Z\",\"iKey\":\"test-key\",\"tags\":{\"ai.cloud.role\":\"test-script\",\"ai.cloud.roleInstance\":\"windows-bat\"},\"data\":{\"baseType\":\"MessageData\",\"baseData\":{\"message\":\"Hello World from Windows Batch!\",\"severityLevel\":\"Information\"}}}"

echo.
echo Done! Check telemetry with: curl http://localhost:5000/api/query

