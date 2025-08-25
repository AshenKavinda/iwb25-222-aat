# Course Service Test Script
# This script tests all the course service endpoints

$baseUrl = "http://localhost:8080/api/course"
$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "Course Service API Test Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Test 1: Add Course
Write-Host "`n1. Testing Add Course..." -ForegroundColor Yellow
$addCourseBody = @{
    name = "Grade 10 Mathematics"
    hall = "Math Lab A"
    year = "2024"
    user_id = 1
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method POST -Body $addCourseBody -Headers $headers
    Write-Host "✓ Add Course: Success" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
    $courseId = $response.data.course_id
} catch {
    Write-Host "✗ Add Course: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Get All Courses
Write-Host "`n2. Testing Get All Courses..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method GET
    Write-Host "✓ Get All Courses: Success" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) courses" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get All Courses: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Get Course by ID (if we have a course ID from add)
if ($courseId) {
    Write-Host "`n3. Testing Get Course by ID..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$courseId" -Method GET
        Write-Host "✓ Get Course by ID: Success" -ForegroundColor Green
        Write-Host "Course: $($response.data.name)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Get Course by ID: Failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Update Course
if ($courseId) {
    Write-Host "`n4. Testing Update Course..." -ForegroundColor Yellow
    $updateCourseBody = @{
        name = "Grade 10 Advanced Mathematics"
        hall = "Math Lab B"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$courseId" -Method PUT -Body $updateCourseBody -Headers $headers
        Write-Host "✓ Update Course: Success" -ForegroundColor Green
        Write-Host "Updated Course: $($response.data.name)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Update Course: Failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 5: Get Available Years
Write-Host "`n5. Testing Get Available Years..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/years" -Method GET
    Write-Host "✓ Get Available Years: Success" -ForegroundColor Green
    Write-Host "Available Years: $($response.data -join ', ')" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get Available Years: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Search Courses by Name
Write-Host "`n6. Testing Search Courses by Name..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/search/name/Math" -Method GET
    Write-Host "✓ Search Courses by Name: Success" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) courses with 'Math' in name" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Search Courses by Name: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Search Courses by Year
Write-Host "`n7. Testing Search Courses by Year..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/search/year/2024" -Method GET
    Write-Host "✓ Search Courses by Year: Success" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) courses for year 2024" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Search Courses by Year: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Search Courses by Name and Year
Write-Host "`n8. Testing Search Courses by Name and Year..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/search/name/Math/year/2024" -Method GET
    Write-Host "✓ Search Courses by Name and Year: Success" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) courses matching criteria" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Search Courses by Name and Year: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 9: Soft Delete Course
if ($courseId) {
    Write-Host "`n9. Testing Soft Delete Course..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$courseId" -Method DELETE
        Write-Host "✓ Soft Delete Course: Success" -ForegroundColor Green
        Write-Host "Deleted Course ID: $($response.course_id)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Soft Delete Course: Failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 10: Get Deleted Courses
Write-Host "`n10. Testing Get Deleted Courses..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/deleted" -Method GET
    Write-Host "✓ Get Deleted Courses: Success" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) deleted courses" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Get Deleted Courses: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 11: Restore Course
if ($courseId) {
    Write-Host "`n11. Testing Restore Course..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$courseId/restore" -Method POST
        Write-Host "✓ Restore Course: Success" -ForegroundColor Green
        Write-Host "Restored Course: $($response.data.name)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Restore Course: Failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n================================" -ForegroundColor Green
Write-Host "Course Service API Tests Completed" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "`nNote: Make sure the server is running before executing this script:" -ForegroundColor Yellow
Write-Host "bal run" -ForegroundColor Cyan
