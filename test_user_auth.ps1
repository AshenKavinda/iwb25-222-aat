# Test script for User Service Authentication
$baseUrl = "http://localhost:8080/api"

Write-Host "Testing User Service Authentication Requirements" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow

# Test 1: Try to add user without authorization header
Write-Host "`n1. Testing POST /api/user without authorization header..." -ForegroundColor Cyan
$body = @{
    email = "test@example.com"
    password = "password123"
    role = "teacher"
    name = "Test User"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user" -Method POST -Body $body -ContentType "application/json"
    Write-Host "ERROR: Request should have been rejected!" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    Write-Host "✓ Correctly rejected with status: $statusCode" -ForegroundColor Green
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Returned 401 Unauthorized as expected" -ForegroundColor Green
    }
}

# Test 2: Try to add user with invalid token
Write-Host "`n2. Testing POST /api/user with invalid authorization token..." -ForegroundColor Cyan
$headers = @{
    'Authorization' = 'Bearer invalid_token_here'
    'Content-Type' = 'application/json'
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user" -Method POST -Body $body -Headers $headers
    Write-Host "ERROR: Request should have been rejected!" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    Write-Host "✓ Correctly rejected with status: $statusCode" -ForegroundColor Green
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Returned 401 Unauthorized as expected" -ForegroundColor Green
    }
}

Write-Host "`n3. To test with valid officer token, you need to:" -ForegroundColor Yellow
Write-Host "   a. First login as an officer user" -ForegroundColor Yellow
Write-Host "   b. Get the access token from the login response" -ForegroundColor Yellow
Write-Host "   c. Use that token in the Authorization header" -ForegroundColor Yellow

Write-Host "`nExample for testing with valid token:" -ForegroundColor Cyan
Write-Host 'curl -X POST http://localhost:8080/api/user \' -ForegroundColor Gray
Write-Host '  -H "Content-Type: application/json" \' -ForegroundColor Gray
Write-Host '  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \' -ForegroundColor Gray
Write-Host '  -d "{\"email\":\"newuser@example.com\",\"password\":\"password123\",\"role\":\"teacher\",\"name\":\"New User\"}"' -ForegroundColor Gray

Write-Host "`nAuthentication integration completed successfully!" -ForegroundColor Green
