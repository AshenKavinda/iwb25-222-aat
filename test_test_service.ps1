# Test API script for Test Service
# This script tests all test service endpoints

$baseUrl = "http://localhost:8080/api"
$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "=== Test Service API Test Script ===" -ForegroundColor Green
Write-Host ""

# Test data
$testData = @{
    t_name = "Mathematics Term Test 1"
    t_type = "tm1"
    year = "2024"
    user_id = 1  # Assuming user_id 1 is an officer
    subject_id = 1  # Assuming subject_id 1 exists
} | ConvertTo-Json

$updateData = @{
    t_name = "Updated Mathematics Term Test 1"
    t_type = "tm2"
    year = "2025"
    subject_id = 2
} | ConvertTo-Json

try {
    # 1. Add new test
    Write-Host "1. Testing POST /api/test (Add Test)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test" -Method POST -Headers $headers -Body $testData
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    $testId = $response.data.test_id
    Write-Host ""

    # 2. Get all tests
    Write-Host "2. Testing GET /api/test (Get All Tests)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 3. Get test by ID
    Write-Host "3. Testing GET /api/test/$testId (Get Test by ID)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/$testId" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 4. Update test
    Write-Host "4. Testing PUT /api/test/$testId (Update Test)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/$testId" -Method PUT -Headers $headers -Body $updateData
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 5. Get tests by type
    Write-Host "5. Testing GET /api/test/types/tm1 (Get Tests by Type)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/types/tm1" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 6. Filter tests by year
    Write-Host "6. Testing GET /api/test/year/2024 (Filter Tests by Year)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/year/2024" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 7. Search tests by name
    Write-Host "7. Testing GET /api/test/search/name/Math (Search Tests by Name)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/search/name/Math" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 8. Get available years
    Write-Host "8. Testing GET /api/test/years (Get Available Years)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/years" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 9. Get tests by subject
    Write-Host "9. Testing GET /api/test/subject/1 (Get Tests by Subject)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/subject/1" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 10. Soft delete test
    Write-Host "10. Testing DELETE /api/test/$testId (Soft Delete Test)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/$testId" -Method DELETE -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 11. Get deleted tests
    Write-Host "11. Testing GET /api/test/deleted (Get Deleted Tests)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/deleted" -Method GET -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 12. Restore test
    Write-Host "12. Testing POST /api/test/$testId/restore (Restore Test)" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/test/$testId/restore" -Method POST -Headers $headers
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    Write-Host ""

    # 13. Test invalid test type
    Write-Host "13. Testing with invalid test type" -ForegroundColor Yellow
    $invalidData = @{
        t_name = "Invalid Test"
        t_type = "invalid_type"
        year = "2024"
        user_id = 1
        subject_id = 1
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/test" -Method POST -Headers $headers -Body $invalidData
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Expected error for invalid test type: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Response: $errorBody" -ForegroundColor Red
        }
    }
    Write-Host ""

    # 14. Test invalid test type filter
    Write-Host "14. Testing GET /api/test/types/invalid_type (Invalid Type Filter)" -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/test/types/invalid_type" -Method GET -Headers $headers
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Expected error for invalid test type filter: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Response: $errorBody" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "=== Test Service API Test Completed ===" -ForegroundColor Green

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Response: $errorBody" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test Types Available: tm1, tm2, tm3" -ForegroundColor Blue
Write-Host "Note: Only users with 'officer' role can access these endpoints" -ForegroundColor Blue
