# Test script for Student Service endpoints

# Base URL for the API
$baseUrl = "http://localhost:8080/api/student"

# First, login to get a token (assuming you have an officer account)
Write-Host "=== Login to get access token ===" -ForegroundColor Green
$loginData = @{
    email = "officer@example.com"
    password = "password123"
} | ConvertTo-Json

$loginResponse = try {
    Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Note: Make sure you have an officer account created first" -ForegroundColor Yellow
    exit 1
}

$token = $loginResponse.data.access_token
Write-Host "Login successful. Token: $($token.Substring(0, 20))..." -ForegroundColor Green

# Headers for authenticated requests
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "=== Testing Student Service Endpoints ===" -ForegroundColor Cyan

# Test 1: Add a new student
Write-Host "`n1. Testing POST /student - Add new student" -ForegroundColor Yellow
$studentData = @{
    parent_nic = "123456789V"
    full_name = "John Doe"
    dob = "2005-01-15"
    user_id = 1
} | ConvertTo-Json

try {
    $addStudentResponse = Invoke-RestMethod -Uri $baseUrl -Method POST -Body $studentData -Headers $headers
    Write-Host "✓ Add student successful" -ForegroundColor Green
    Write-Host "Response: $($addStudentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
    $studentId = $addStudentResponse.data.student_id
} catch {
    Write-Host "✗ Add student failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
    $studentId = 1  # Use default for testing other endpoints
}

# Test 2: Get all students
Write-Host "`n2. Testing GET /student - Get all students" -ForegroundColor Yellow
try {
    $allStudentsResponse = Invoke-RestMethod -Uri $baseUrl -Method GET -Headers $headers
    Write-Host "✓ Get all students successful" -ForegroundColor Green
    Write-Host "Response: $($allStudentsResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get all students failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 3: Get student by ID
Write-Host "`n3. Testing GET /student/$studentId - Get student by ID" -ForegroundColor Yellow
try {
    $studentByIdResponse = Invoke-RestMethod -Uri "$baseUrl/$studentId" -Method GET -Headers $headers
    Write-Host "✓ Get student by ID successful" -ForegroundColor Green
    Write-Host "Response: $($studentByIdResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get student by ID failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 4: Update student
Write-Host "`n4. Testing PUT /student/$studentId - Update student" -ForegroundColor Yellow
$updateData = @{
    full_name = "John Updated Doe"
    parent_nic = "987654321V"
} | ConvertTo-Json

try {
    $updateStudentResponse = Invoke-RestMethod -Uri "$baseUrl/$studentId" -Method PUT -Body $updateData -Headers $headers
    Write-Host "✓ Update student successful" -ForegroundColor Green
    Write-Host "Response: $($updateStudentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Update student failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 5: Search students by name
Write-Host "`n5. Testing GET /student/search?name=John - Search students by name" -ForegroundColor Yellow
try {
    $searchResponse = Invoke-RestMethod -Uri "$baseUrl/search?name=John" -Method GET -Headers $headers
    Write-Host "✓ Search students by name successful" -ForegroundColor Green
    Write-Host "Response: $($searchResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Search students by name failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 6: Soft delete student
Write-Host "`n6. Testing DELETE /student/$studentId - Soft delete student" -ForegroundColor Yellow
try {
    $deleteStudentResponse = Invoke-RestMethod -Uri "$baseUrl/$studentId" -Method DELETE -Headers $headers
    Write-Host "✓ Soft delete student successful" -ForegroundColor Green
    Write-Host "Response: $($deleteStudentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Soft delete student failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 7: Get deleted students
Write-Host "`n7. Testing GET /student/deleted - Get all deleted students" -ForegroundColor Yellow
try {
    $deletedStudentsResponse = Invoke-RestMethod -Uri "$baseUrl/deleted" -Method GET -Headers $headers
    Write-Host "✓ Get deleted students successful" -ForegroundColor Green
    Write-Host "Response: $($deletedStudentsResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Get deleted students failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 8: Restore student
Write-Host "`n8. Testing POST /student/$studentId/restore - Restore student" -ForegroundColor Yellow
try {
    $restoreStudentResponse = Invoke-RestMethod -Uri "$baseUrl/$studentId/restore" -Method POST -Headers $headers
    Write-Host "✓ Restore student successful" -ForegroundColor Green
    Write-Host "Response: $($restoreStudentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✗ Restore student failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

# Test 9: Test unauthorized access (without token)
Write-Host "`n9. Testing unauthorized access - GET /api/student without token" -ForegroundColor Yellow
try {
    $unauthorizedResponse = Invoke-RestMethod -Uri $baseUrl -Method GET
    Write-Host "✗ Unauthorized access should have failed!" -ForegroundColor Red
} catch {
    Write-Host "✓ Unauthorized access properly rejected" -ForegroundColor Green
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor White
    }
}

# Test 10: Test invalid student ID
Write-Host "`n10. Testing GET /api/student/999999 - Get non-existent student" -ForegroundColor Yellow
try {
    $invalidStudentResponse = Invoke-RestMethod -Uri "$baseUrl/999999" -Method GET -Headers $headers
    Write-Host "Response: $($invalidStudentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "✓ Non-existent student properly handled" -ForegroundColor Green
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

Write-Host "`n=== Student Service testing completed ===" -ForegroundColor Cyan
