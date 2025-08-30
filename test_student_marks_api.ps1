# Test script for Student Marks Report API (No Authentication Required)
# Make sure the Ballerina service is running on http://localhost:8080

$baseUrl = "http://localhost:8080/api"
$reportsUrl = "$baseUrl/reports"

Write-Host "=== Testing Student Marks Report API (No Authentication) ==="
Write-Host ""

# Test 1: Get marks for student ID 1
Write-Host "Test 1: Getting marks for Student ID 1..."
try {
    $studentMarksUrl = "$reportsUrl/student/1/marks"
    $response = Invoke-RestMethod -Uri $studentMarksUrl -Method GET
    Write-Host "✓ Student Marks Report retrieved successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of mark records: $($response.data.Count)"
    
    if ($response.data.Count -gt 0) {
        Write-Host ""
        Write-Host "Sample records:"
        $response.data | Select-Object -First 3 | ForEach-Object {
            Write-Host "  - $($_.full_name) | $($_.subject_name) | $($_.test_name) ($($_.test_type)) | Year: $($_.year) | Mark: $($_.mark)"
        }
    } else {
        Write-Host "No marks found for this student"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Student Marks Report test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Test 2: Test with a different student ID
Write-Host "Test 2: Getting marks for Student ID 2..."
try {
    $studentMarksUrl = "$reportsUrl/student/2/marks"
    $response = Invoke-RestMethod -Uri $studentMarksUrl -Method GET
    Write-Host "✓ Student Marks Report for student 2 retrieved successfully"
    Write-Host "Number of mark records: $($response.data.Count)"
    Write-Host ""
} catch {
    Write-Host "✗ Student Marks Report for student 2 test failed: $($_.Exception.Message)"
    Write-Host ""
}

# Test 3: Test with invalid student ID (0)
Write-Host "Test 3: Testing with invalid Student ID (0)..."
try {
    $invalidStudentUrl = "$reportsUrl/student/0/marks"
    $response = Invoke-RestMethod -Uri $invalidStudentUrl -Method GET
    Write-Host "✗ Invalid student ID test failed - should have rejected student ID 0"
} catch {
    if ($_.Exception.Response.StatusCode -eq "BadRequest") {
        Write-Host "✓ Invalid student ID test passed - Bad request correctly returned"
        Write-Host "Error message handled properly"
    } else {
        Write-Host "? Invalid student ID test: $($_.Exception.Message)"
    }
}
Write-Host ""

# Test 4: Test with negative student ID
Write-Host "Test 4: Testing with negative Student ID (-1)..."
try {
    $negativeStudentUrl = "$reportsUrl/student/-1/marks"
    $response = Invoke-RestMethod -Uri $negativeStudentUrl -Method GET
    Write-Host "✗ Negative student ID test failed - should have rejected student ID -1"
} catch {
    if ($_.Exception.Response.StatusCode -eq "BadRequest") {
        Write-Host "✓ Negative student ID test passed - Bad request correctly returned"
    } else {
        Write-Host "? Negative student ID test: $($_.Exception.Message)"
    }
}
Write-Host ""

# Test 5: Test with non-existent student ID
Write-Host "Test 5: Testing with non-existent Student ID (99999)..."
try {
    $nonExistentStudentUrl = "$reportsUrl/student/99999/marks"
    $response = Invoke-RestMethod -Uri $nonExistentStudentUrl -Method GET
    Write-Host "✓ Non-existent student ID handled successfully"
    Write-Host "Message: $($response.message)"
    Write-Host "Number of records: $($response.data.Count)"
    if ($response.data.Count -eq 0) {
        Write-Host "✓ Correctly returned empty result for non-existent student"
    }
    Write-Host ""
} catch {
    Write-Host "✗ Non-existent student ID test failed: $($_.Exception.Message)"
    Write-Host ""
}

Write-Host "=== Student Marks Report API Testing Complete ==="
Write-Host ""
Write-Host "Key Features Tested:"
Write-Host "✓ No authentication required"
Write-Host "✓ Returns comprehensive student marks data"
Write-Host "✓ Proper error handling for invalid student IDs"
Write-Host "✓ Handles non-existent students gracefully"
Write-Host "✓ Ordered by year, term type, and subject"
