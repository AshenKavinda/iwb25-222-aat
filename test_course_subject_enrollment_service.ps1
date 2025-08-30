# Course Subject Enrollment Service Test Script

# PowerShell script to test the Course Subject Enrollment Service endpoints

# Base URL for the API
$baseUrl = "http://localhost:8080/api/course-subject-enrollment"

# Function to make API requests with authorization
function Invoke-APIRequest {
    param(
        [string]$url,
        [string]$method = "GET",
        [string]$body = $null,
        [string]$authToken = "Bearer YOUR_JWT_TOKEN_HERE"
    )
    
    $headers = @{
        "Authorization" = $authToken
        "Content-Type" = "application/json"
    }
    
    try {
        if ($body) {
            $response = Invoke-RestMethod -Uri $url -Method $method -Headers $headers -Body $body
        } else {
            $response = Invoke-RestMethod -Uri $url -Method $method -Headers $headers
        }
        return $response
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "=== Course Subject Enrollment Service API Tests ===" -ForegroundColor Green

# Test 1: Add course subject enrollment
Write-Host "`n1. Testing Add Course Subject Enrollment (POST)" -ForegroundColor Yellow
$addRequest = @{
    subject_id = 1
    course_id = 1
    teacher_id = 2  # Should be a user with teacher role
    user_id = 3     # Should be a user with officer role
} | ConvertTo-Json

Write-Host "Request Body: $addRequest"
Write-Host "Testing: POST $baseUrl"
# Uncomment the line below when you have a valid JWT token
# $result = Invoke-APIRequest -url $baseUrl -method "POST" -body $addRequest
# Write-Host "Response: $($result | ConvertTo-Json -Depth 3)"

# Test 2: Update course subject enrollment (only subject_id)
Write-Host "`n2. Testing Update Course Subject Enrollment (PUT)" -ForegroundColor Yellow
$updateRequest = @{
    subject_id = 2
} | ConvertTo-Json

$recordId = 1  # Replace with actual record ID
Write-Host "Request Body: $updateRequest"
Write-Host "Testing: PUT $baseUrl/$recordId"
# Uncomment the line below when you have a valid JWT token and record ID
# $result = Invoke-APIRequest -url "$baseUrl/$recordId" -method "PUT" -body $updateRequest
# Write-Host "Response: $($result | ConvertTo-Json -Depth 3)"

# Test 3: Get course subject enrollments by course ID
Write-Host "`n3. Testing Get Enrollments by Course ID (GET)" -ForegroundColor Yellow
$courseId = 1  # Replace with actual course ID
Write-Host "Testing: GET $baseUrl/course/$courseId"
# Uncomment the line below when you have a valid JWT token and course ID
# $result = Invoke-APIRequest -url "$baseUrl/course/$courseId"
# Write-Host "Response: $($result | ConvertTo-Json -Depth 3)"

# Test 4: Get course subject enrollments by teacher ID with details
Write-Host "`n4. Testing Get Enrollments by Teacher ID with Details (GET)" -ForegroundColor Yellow
$teacherId = 2  # Replace with actual teacher ID
Write-Host "Testing: GET $baseUrl/teacher/$teacherId"
# Uncomment the line below when you have a valid JWT token and teacher ID
# $result = Invoke-APIRequest -url "$baseUrl/teacher/$teacherId"
# Write-Host "Response: $($result | ConvertTo-Json -Depth 3)"

# Test 5: Delete course subject enrollment
Write-Host "`n5. Testing Delete Course Subject Enrollment (DELETE)" -ForegroundColor Yellow
$recordId = 1  # Replace with actual record ID
Write-Host "Testing: DELETE $baseUrl/$recordId"
# Uncomment the line below when you have a valid JWT token and record ID
# $result = Invoke-APIRequest -url "$baseUrl/$recordId" -method "DELETE"
# Write-Host "Response: $($result | ConvertTo-Json -Depth 3)"

Write-Host "`n=== Test Instructions ===" -ForegroundColor Cyan
Write-Host "1. Start the Ballerina service: 'bal run'"
Write-Host "2. Obtain a JWT token by logging in as an officer user"
Write-Host "3. Replace 'YOUR_JWT_TOKEN_HERE' with the actual token"
Write-Host "4. Uncomment the test lines you want to run"
Write-Host "5. Update the IDs with actual values from your database"
Write-Host "6. Run this script: '.\test_course_subject_enrollment_service.ps1'"

Write-Host "`n=== API Endpoints Summary ===" -ForegroundColor Cyan
Write-Host "POST   $baseUrl                    - Add course subject enrollment"
Write-Host "PUT    $baseUrl/{record_id}        - Update course subject enrollment (only subject_id)"
Write-Host "DELETE $baseUrl/{record_id}        - Delete course subject enrollment"
Write-Host "GET    $baseUrl/course/{course_id} - Get all enrollments by course ID"
Write-Host "GET    $baseUrl/teacher/{teacher_id} - Get all enrollments by teacher ID with details"

Write-Host "`n=== Validation Rules ===" -ForegroundColor Cyan
Write-Host "- Only users with 'officer' role can access these endpoints"
Write-Host "- Subject ID must exist and not be deleted"
Write-Host "- Course ID must exist and not be deleted"
Write-Host "- Teacher ID must exist and have 'teacher' role"
Write-Host "- User ID must exist and have 'officer' role"
Write-Host "- Subject-Course-Teacher combinations must be unique"
Write-Host "- Hard delete is used (no soft delete)"
