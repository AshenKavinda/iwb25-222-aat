# PowerShell script to test authentication endpoints

# Test Registration/Signup
Write-Host "Testing User Registration..." -ForegroundColor Green

$registerData = @{
    email = "testuser@example.com"
    password = "testPassword123"
    name = "Test User"
    phone_number = "1234567890"
    dob = "1990-01-01"
} | ConvertTo-Json

Write-Host "Registration JSON:" -ForegroundColor Yellow
Write-Host $registerData

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "Registration successful!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

# Test Login
Write-Host "`nTesting User Login..." -ForegroundColor Green

$loginData = @{
    email = "testuser@example.com"
    password = "testPassword123"
} | ConvertTo-Json

Write-Host "Login JSON:" -ForegroundColor Yellow
Write-Host $loginData

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host ($loginResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
    # Store tokens for further testing
    $accessToken = $loginResponse.access_token
    $refreshToken = $loginResponse.refresh_token
    
    # Test Get Current User
    Write-Host "`nTesting Get Current User..." -ForegroundColor Green
    $headers = @{ Authorization = "Bearer $accessToken" }
    $userResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/me" -Method GET -Headers $headers
    Write-Host "Current user:" -ForegroundColor Green
    Write-Host ($userResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Health Endpoint
Write-Host "`nTesting Health Endpoint..." -ForegroundColor Green
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET
    Write-Host "Health check successful!" -ForegroundColor Green
    Write-Host ($healthResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}
