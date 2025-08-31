# User Management API Test Script
# This PowerShell script tests all the user management API endpoints

param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$Token = ""
)

# Set the base URL for the API
$apiUrl = "$BaseUrl/api/user"

# Headers with authorization
$headers = @{
    "Content-Type" = "application/json"
}

if ($Token) {
    $headers["Authorization"] = "Bearer $Token"
}

Write-Host "Testing User Management API Endpoints" -ForegroundColor Green
Write-Host "Base URL: $apiUrl" -ForegroundColor Yellow
Write-Host ""

# Test 1: Get all active users
Write-Host "1. Testing GET /api/user (Get all active users)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -Headers $headers
    Write-Host "✅ Success: GET /api/user" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: GET /api/user - $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Get deleted users
Write-Host "2. Testing GET /api/user/deleted (Get deleted users)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiUrl/deleted" -Method GET -Headers $headers
    Write-Host "✅ Success: GET /api/user/deleted" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: GET /api/user/deleted - $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Search users by email
Write-Host "3. Testing GET /api/user/search?email=test (Search users by email)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiUrl/search?email=test" -Method GET -Headers $headers
    Write-Host "✅ Success: GET /api/user/search?email=test" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: GET /api/user/search - $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Add new user (Example data)
Write-Host "4. Testing POST /api/user (Add new user)" -ForegroundColor Cyan
$newUser = @{
    email = "test.user@example.com"
    password = "testpassword123"
    role = "guest"
    name = "Test User"
    phone_number = "+1234567890"
    dob = "1990-01-01"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body $newUser
    Write-Host "✅ Success: POST /api/user" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
    $testUserId = $response.data.user.user_id
} catch {
    Write-Host "❌ Error: POST /api/user - $($_.Exception.Message)" -ForegroundColor Red
    $testUserId = $null
}
Write-Host ""

if ($testUserId) {
    # Test 5: Get user by ID
    Write-Host "5. Testing GET /api/user/$testUserId (Get user by ID)" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/$testUserId" -Method GET -Headers $headers
        Write-Host "✅ Success: GET /api/user/$testUserId" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error: GET /api/user/$testUserId - $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # Test 6: Update user
    Write-Host "6. Testing PUT /api/user/$testUserId (Update user)" -ForegroundColor Cyan
    $updateUser = @{
        name = "Updated Test User"
        phone_number = "+0987654321"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/$testUserId" -Method PUT -Headers $headers -Body $updateUser
        Write-Host "✅ Success: PUT /api/user/$testUserId" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error: PUT /api/user/$testUserId - $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # Test 7: Delete user
    Write-Host "7. Testing DELETE /api/user/$testUserId (Delete user)" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/$testUserId" -Method DELETE -Headers $headers
        Write-Host "✅ Success: DELETE /api/user/$testUserId" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error: DELETE /api/user/$testUserId - $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # Test 8: Restore user
    Write-Host "8. Testing POST /api/user/$testUserId/restore (Restore user)" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/$testUserId/restore" -Method POST -Headers $headers
        Write-Host "✅ Success: POST /api/user/$testUserId/restore" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error: POST /api/user/$testUserId/restore - $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "User Management API Testing Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "API Endpoints Summary:" -ForegroundColor Yellow
Write-Host "  GET    /api/user                     - Get all active users" -ForegroundColor White
Write-Host "  GET    /api/user/{id}                - Get user by ID" -ForegroundColor White
Write-Host "  POST   /api/user                     - Add new user" -ForegroundColor White
Write-Host "  PUT    /api/user/{id}                - Update user" -ForegroundColor White
Write-Host "  DELETE /api/user/{id}                - Delete user (soft delete)" -ForegroundColor White
Write-Host "  POST   /api/user/{id}/restore        - Restore deleted user" -ForegroundColor White
Write-Host "  GET    /api/user/deleted             - Get deleted users" -ForegroundColor White
Write-Host "  GET    /api/user/search?email={term} - Search users by email" -ForegroundColor White
