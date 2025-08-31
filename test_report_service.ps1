# Test script for Report Service APIs
# Make sure the Ballerina service is running on http://localhost:8080

$baseUrl = "http://localhost:8080/api"
$authUrl = "$baseUrl/auth/login"
$reportsUrl = "$baseUrl/reports"

# Step 1: Login to get access token (using manager credentials)
Write-Host "=== Testing Report Service APIs ==="
Write-Host ""

Write-Host "Step 1: Login to get access token..."
$loginBody = @{
    email = "manager@example.com"
    password = "manager123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri $authUrl -Method POST -Body $loginBody -ContentType "application/json"
    $accessToken = $loginResponse.data.access_token
    Write-Host "✓ Login successful"
    Write-Host "Access Token: $($accessToken.Substring(0,50))..."
    Write-Host ""
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)"
    Write-Host "Please make sure you have a manager user with email 'manager@example.com' and password 'manager123'"
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Step 2: Test Top Performing Students
Write-Host "Step 2: Testing Top Performing Students Report..."
try {
    $topStudentsUrl = "$reportsUrl/topstudents?year=2024&term_type=tm1&limitCount=5"
    $response = Invoke-RestMethod -Uri $topStudentsUrl -Method GET -Headers $headers
    Write-Host "✓ Top Performing Students retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of students: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host "Top student: $($response.data[0].full_name) - Total marks: $($response.data[0].total_marks)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Top Performing Students test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 3: Test Average Marks by Subject
Write-Host "Step 3: Testing Average Marks by Subject Report..."
try {
    $avgMarksUrl = "$reportsUrl/avgmarks?year=2024&term_type=tm2"
    $response = Invoke-RestMethod -Uri $avgMarksUrl -Method GET -Headers $headers
    Write-Host "✓ Average Marks by Subject retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of subject records: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host "Top subject: $($response.data[0].subject_name) - Average: $($response.data[0].avg_mark)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Average Marks by Subject test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 4: Test Teacher Performance
Write-Host "Step 4: Testing Teacher Performance Report..."
try {
    $teacherPerfUrl = "$reportsUrl/teacherperformance"
    $response = Invoke-RestMethod -Uri $teacherPerfUrl -Method GET -Headers $headers
    Write-Host "✓ Teacher Performance retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of teacher records: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host "Top teacher: $($response.data[0].teacher_name) - Average student marks: $($response.data[0].avg_student_marks)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Teacher Performance test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 5: Test Student Progress
Write-Host "Step 5: Testing Student Progress Report..."
try {
    $studentProgressUrl = "$reportsUrl/studentprogress?year=2024"
    $response = Invoke-RestMethod -Uri $studentProgressUrl -Method GET -Headers $headers
    Write-Host "✓ Student Progress retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of progress records: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        $firstRecord = $response.data[0]
        Write-Host "Sample: $($firstRecord.full_name) - $($firstRecord.subject_name)"
        Write-Host "  TM1: $($firstRecord.tm1_marks), TM2: $($firstRecord.tm2_marks), TM3: $($firstRecord.tm3_marks)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Student Progress test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 6: Test Low Performing Subjects
Write-Host "Step 6: Testing Low Performing Subjects Report..."
try {
    $lowPerfUrl = "$reportsUrl/lowperformingsubjects?year=2024&threshold=50"
    $response = Invoke-RestMethod -Uri $lowPerfUrl -Method GET -Headers $headers
    Write-Host "✓ Low Performing Subjects retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of low performing subjects: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host "Lowest: $($response.data[0].subject_name) - Average: $($response.data[0].avg_marks)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Low Performing Subjects test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 7: Test Top Performing Courses
Write-Host "Step 7: Testing Top Performing Courses Report..."
try {
    $topCoursesUrl = "$reportsUrl/topcourses?year=2024&term_type=tm3"
    $response = Invoke-RestMethod -Uri $topCoursesUrl -Method GET -Headers $headers
    Write-Host "✓ Top Performing Courses retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of courses: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        Write-Host "Top course: $($response.data[0].course_name) - Average: $($response.data[0].avg_marks)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Top Performing Courses test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Step 8: Test Authorization (using invalid role)
Write-Host "Step 8: Testing Authorization (should fail for non-manager)..."
try {
    # Try to login with officer credentials (assuming they exist)
    $officerLoginBody = @{
        email = "officer@example.com"
        password = "officer123"
    } | ConvertTo-Json
    
    $officerLoginResponse = Invoke-RestMethod -Uri $authUrl -Method POST -Body $officerLoginBody -ContentType "application/json"
    $officerToken = $officerLoginResponse.data.access_token
    
    $officerHeaders = @{
        "Authorization" = "Bearer $officerToken"
        "Content-Type" = "application/json"
    }
    
    # Try to access reports with officer token (should fail)
    $topStudentsUrl = "$reportsUrl/topstudents?year=2024&term_type=tm1"
    $response = Invoke-RestMethod -Uri $topStudentsUrl -Method GET -Headers $officerHeaders
    Write-Host "✗ Authorization test failed - Officer should not have access"
} catch {
    if ($_.Exception.Response.StatusCode -eq "Forbidden") {
        Write-Host "✓ Authorization test passed - Access correctly denied for non-manager"
    } else {
        Write-Host "✗ Authorization test failed with unexpected error: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "=== Report Service API Testing Complete ==="

# Test with invalid parameters
Write-Host ""
Write-Host "Step 9: Testing Invalid Parameters..."
try {
    $invalidUrl = "$reportsUrl/topstudents?year=2024&term_type=invalid"
    $response = Invoke-RestMethod -Uri $invalidUrl -Method GET -Headers $headers
    Write-Host "✗ Invalid parameter test failed - should have rejected invalid term_type"
} catch {
    if ($_.Exception.Response.StatusCode -eq "BadRequest") {
        Write-Host "✓ Invalid parameter test passed - Bad request correctly returned"
    } else {
        Write-Host "? Invalid parameter test: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "=== All Tests Complete ==="

# Step 10: Test Student Marks Report (No Authentication)
Write-Host ""
Write-Host "Step 10: Testing Student Marks Report (No Authentication Required)..."
try {
    # Test with a sample student ID (assuming student ID 1 exists)
    $studentMarksUrl = "$reportsUrl/student/1/marks"
    $response = Invoke-RestMethod -Uri $studentMarksUrl -Method GET
    Write-Host "✓ Student Marks Report retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of mark records: $($response.data.Count)"
    if ($response.data.Count -gt 0) {
        $firstMark = $response.data[0]
        Write-Host "Sample record: $($firstMark.full_name) - $($firstMark.subject_name) - $($firstMark.test_name): $($firstMark.mark)"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Student Marks Report test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Test with invalid student ID
Write-Host "Step 11: Testing Invalid Student ID..."
try {
    $invalidStudentUrl = "$reportsUrl/student/0/marks"
    $response = Invoke-RestMethod -Uri $invalidStudentUrl -Method GET
    Write-Host "✗ Invalid student ID test failed - should have rejected student ID 0"
} catch {
    if ($_.Exception.Response.StatusCode -eq "BadRequest") {
        Write-Host "✓ Invalid student ID test passed - Bad request correctly returned"
    } else {
        Write-Host "? Invalid student ID test: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "=== All Tests Complete ==="
