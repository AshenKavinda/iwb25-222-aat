# Test the Authentication API

# First, start the server
# bal run

# Then test the endpoints using PowerShell

# 1. Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor Green
$healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET
Write-Host "Health Response: $($healthResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan

# 2. Register a new guest user
Write-Host "`n2. Testing User Registration..." -ForegroundColor Green
$registerBody = @{
    email = "testuser@example.com"
    password = "testpassword123"
    name = "Test User"
    phone_number = "1234567890"
    dob = "1990-01-01"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "Registration Response: $($registerResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    $accessToken = $registerResponse.access_token
    $refreshToken = $registerResponse.refresh_token
} catch {
    Write-Host "Registration failed (user might already exist): $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Try logging in instead
    Write-Host "`n2b. Trying to login with existing user..." -ForegroundColor Green
    $loginBody = @{
        email = "testuser@example.com"
        password = "testpassword123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Login Response: $($loginResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    $accessToken = $loginResponse.access_token
    $refreshToken = $loginResponse.refresh_token
}

# 3. Get current user profile
Write-Host "`n3. Testing Get Current User..." -ForegroundColor Green
$headers = @{
    Authorization = "Bearer $accessToken"
}
$userResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/me" -Method GET -Headers $headers
Write-Host "User Profile Response: $($userResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan

# 4. Validate token
Write-Host "`n4. Testing Token Validation..." -ForegroundColor Green
$validateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/validate" -Method POST -Headers $headers
Write-Host "Token Validation Response: $($validateResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan

# 5. Refresh token
Write-Host "`n5. Testing Token Refresh..." -ForegroundColor Green
$refreshBody = @{
    refresh_token = $refreshToken
} | ConvertTo-Json

$refreshResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/refresh" -Method POST -Body $refreshBody -ContentType "application/json"
Write-Host "Token Refresh Response: $($refreshResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan

Write-Host "`nAll tests completed successfully!" -ForegroundColor Green
Write-Host "You can now use these endpoints in your application." -ForegroundColor Cyan
