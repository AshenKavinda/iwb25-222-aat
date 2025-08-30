# Student Course Service API Test Script
# Test all endpoints for the student course service

# Configuration
$baseUrl = "http://localhost:8080/api"
$studentCourseEndpoint = "$baseUrl/student-course"
$authEndpoint = "$baseUrl/auth"

# Test data
$loginData = @{
    email = "officer@example.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "=== Student Course Service API Tests ===" -ForegroundColor Green

# Step 1: Login to get access token
Write-Host "`n1. Logging in to get access token..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "$authEndpoint/login" -Method POST -Body $loginData -ContentType "application/json"
    $accessToken = $loginResponse.data.access_token
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }
    Write-Host "✓ Login successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test adding students to course (bulk insertion)
Write-Host "`n2. Testing bulk add students to course..." -ForegroundColor Yellow
$addStudentsData = @{
    course_id = 1
    student_ids = @(1, 2, 3)
    user_id = 1
} | ConvertTo-Json

try {
    $addResponse = Invoke-RestMethod -Uri $studentCourseEndpoint -Method POST -Body $addStudentsData -Headers $headers
    Write-Host "✓ Add students to course successful" -ForegroundColor Green
    Write-Host "Response: $($addResponse.message)" -ForegroundColor Cyan
    $recordIds = $addResponse.data | ForEach-Object { $_.record_id }
    Write-Host "Created record IDs: $($recordIds -join ', ')" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Add students to course failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test getting student courses by student ID
Write-Host "`n3. Testing get student courses by student ID..." -ForegroundColor Yellow
try {
    $studentCoursesResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/student/1" -Method GET -Headers $headers
    Write-Host "✓ Get student courses by student ID successful" -ForegroundColor Green
    Write-Host "Response: $($studentCoursesResponse.message)" -ForegroundColor Cyan
    Write-Host "Found $($studentCoursesResponse.data.Count) course enrollments" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get student courses by student ID failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Test getting student courses by course ID
Write-Host "`n4. Testing get student courses by course ID..." -ForegroundColor Yellow
try {
    $courseStudentsResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/course/1" -Method GET -Headers $headers
    Write-Host "✓ Get student courses by course ID successful" -ForegroundColor Green
    Write-Host "Response: $($courseStudentsResponse.message)" -ForegroundColor Cyan
    Write-Host "Found $($courseStudentsResponse.data.Count) student enrollments" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get student courses by course ID failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Test getting student course by record ID
Write-Host "`n5. Testing get student course by record ID..." -ForegroundColor Yellow
try {
    $recordResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/1" -Method GET -Headers $headers
    Write-Host "✓ Get student course by record ID successful" -ForegroundColor Green
    Write-Host "Response: $($recordResponse.message)" -ForegroundColor Cyan
    Write-Host "Record ID: $($recordResponse.data.record_id), Student ID: $($recordResponse.data.student_id), Course ID: $($recordResponse.data.course_id)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get student course by record ID failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Test updating student course record
Write-Host "`n6. Testing update student course record..." -ForegroundColor Yellow
$updateData = @{
    student_id = 2
    course_id = 1
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/1" -Method PUT -Body $updateData -Headers $headers
    Write-Host "✓ Update student course record successful" -ForegroundColor Green
    Write-Host "Response: $($updateResponse.message)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Update student course record failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Test getting student courses with details by student ID
Write-Host "`n7. Testing get student courses with details by student ID..." -ForegroundColor Yellow
try {
    $detailsResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/student/1/details" -Method GET -Headers $headers
    Write-Host "✓ Get student courses with details successful" -ForegroundColor Green
    Write-Host "Response: $($detailsResponse.message)" -ForegroundColor Cyan
    if ($detailsResponse.data.Count -gt 0) {
        $firstRecord = $detailsResponse.data[0]
        Write-Host "Sample record - Student: $($firstRecord.student_name), Course: $($firstRecord.course_name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Get student courses with details failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 8: Test getting student courses with details by course ID
Write-Host "`n8. Testing get student courses with details by course ID..." -ForegroundColor Yellow
try {
    $courseDetailsResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/course/1/details" -Method GET -Headers $headers
    Write-Host "✓ Get course students with details successful" -ForegroundColor Green
    Write-Host "Response: $($courseDetailsResponse.message)" -ForegroundColor Cyan
    if ($courseDetailsResponse.data.Count -gt 0) {
        $firstRecord = $courseDetailsResponse.data[0]
        Write-Host "Sample record - Student: $($firstRecord.student_name), Course: $($firstRecord.course_name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Get course students with details failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Test deleting student course record (hard delete)
Write-Host "`n9. Testing delete student course record..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-RestMethod -Uri "$studentCourseEndpoint/1" -Method DELETE -Headers $headers
    Write-Host "✓ Delete student course record successful" -ForegroundColor Green
    Write-Host "Response: $($deleteResponse.message)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Delete student course record failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Test validation errors
Write-Host "`n10. Testing validation errors..." -ForegroundColor Yellow

# Test with empty student IDs array
Write-Host "Testing empty student IDs array..." -ForegroundColor Gray
$invalidData = @{
    course_id = 1
    student_ids = @()
    user_id = 1
} | ConvertTo-Json

try {
    $errorResponse = Invoke-RestMethod -Uri $studentCourseEndpoint -Method POST -Body $invalidData -Headers $headers
    Write-Host "✗ Should have failed with empty student IDs" -ForegroundColor Red
} catch {
    Write-Host "✓ Correctly rejected empty student IDs array" -ForegroundColor Green
}

# Test with invalid course ID
Write-Host "Testing invalid course ID..." -ForegroundColor Gray
$invalidCourseData = @{
    course_id = -1
    student_ids = @(1)
    user_id = 1
} | ConvertTo-Json

try {
    $errorResponse = Invoke-RestMethod -Uri $studentCourseEndpoint -Method POST -Body $invalidCourseData -Headers $headers
    Write-Host "✗ Should have failed with invalid course ID" -ForegroundColor Red
} catch {
    Write-Host "✓ Correctly rejected invalid course ID" -ForegroundColor Green
}

# Test without authorization header
Write-Host "Testing without authorization header..." -ForegroundColor Gray
try {
    $errorResponse = Invoke-RestMethod -Uri $studentCourseEndpoint -Method GET
    Write-Host "✗ Should have failed without authorization" -ForegroundColor Red
} catch {
    Write-Host "✓ Correctly rejected request without authorization" -ForegroundColor Green
}

Write-Host "`n=== Student Course Service API Tests Completed ===" -ForegroundColor Green
Write-Host "All major endpoints have been tested." -ForegroundColor Cyan
