# Test script for User Service GET endpoints

# Base URL for the API
$baseUrl = "http://localhost:8080/users"

# First, login to get a token (assuming you have an officer account)
Write-Host "=== Login to get access token ===" -ForegroundColor Green
$loginData = @{
    email = "officer@example.com"
    password = "password123"
} | ConvertTo-Json

$loginResponse = try {
    Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method POST -Body $loginData -ContentType "application/json"
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$token = $loginResponse.data.access_token
Write-Host "Login successful. Token: $($token.Substring(0, 20))..." -ForegroundColor Green

# Headers for authenticated requests
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`n=== Testing GET endpoints ===" -ForegroundColor Cyan

# Test 1: Get all users
Write-Host "`n1. Testing GET /users - Get all active users" -ForegroundColor Yellow
try {
    $allUsersResponse = Invoke-RestMethod -Uri $baseUrl -Method GET -Headers $headers
    Write-Host "✓ Get all users successful" -ForegroundColor Green
    Write-Host "Response: $($allUsersResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get all users failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 2: Get user by ID (assuming user ID 1 exists)
Write-Host "`n2. Testing GET /users/1 - Get user by ID" -ForegroundColor Yellow
try {
    $userByIdResponse = Invoke-RestMethod -Uri "$baseUrl/1" -Method GET -Headers $headers
    Write-Host "✓ Get user by ID successful" -ForegroundColor Green
    Write-Host "Response: $($userByIdResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get user by ID failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 3: Get deleted users
Write-Host "`n3. Testing GET /users/deleted - Get all deleted users" -ForegroundColor Yellow
try {
    $deletedUsersResponse = Invoke-RestMethod -Uri "$baseUrl/deleted" -Method GET -Headers $headers
    Write-Host "✓ Get deleted users successful" -ForegroundColor Green
    Write-Host "Response: $($deletedUsersResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get deleted users failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 4: Search users by email
Write-Host "`n4. Testing GET /users/search?email=test - Search users by email" -ForegroundColor Yellow
try {
    $searchResponse = Invoke-RestMethod -Uri "$baseUrl/search?email=test" -Method GET -Headers $headers
    Write-Host "✓ Search users by email successful" -ForegroundColor Green
    Write-Host "Response: $($searchResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Search users by email failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 5: Search users by full email
Write-Host "`n5. Testing GET /users/search?email=officer@example.com - Search by full email" -ForegroundColor Yellow
try {
    $searchFullResponse = Invoke-RestMethod -Uri "$baseUrl/search?email=officer@example.com" -Method GET -Headers $headers
    Write-Host "✓ Search users by full email successful" -ForegroundColor Green
    Write-Host "Response: $($searchFullResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Search users by full email failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 6: Test unauthorized access (without token)
Write-Host "`n6. Testing unauthorized access - GET /users without token" -ForegroundColor Yellow
try {
    $unauthorizedResponse = Invoke-RestMethod -Uri $baseUrl -Method GET
    Write-Host "✗ Unauthorized access should have failed!" -ForegroundColor Red
} catch {
    Write-Host "✓ Unauthorized access properly rejected" -ForegroundColor Green
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor White
    }
}

# Test 7: Test invalid user ID
Write-Host "`n7. Testing GET /users/999999 - Get non-existent user" -ForegroundColor Yellow
try {
    $invalidUserResponse = Invoke-RestMethod -Uri "$baseUrl/999999" -Method GET -Headers $headers
    Write-Host "Response: $($invalidUserResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✓ Non-existent user properly handled" -ForegroundColor Green
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 8: Test empty email search
Write-Host "`n8. Testing GET /users/search?email= - Search with empty email" -ForegroundColor Yellow
try {
    $emptyEmailResponse = Invoke-RestMethod -Uri "$baseUrl/search?email=" -Method GET -Headers $headers
    Write-Host "Response: $($emptyEmailResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✓ Empty email search properly handled" -ForegroundColor Green
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

Write-Host "`n=== GET endpoints testing completed ===" -ForegroundColor Cyan
