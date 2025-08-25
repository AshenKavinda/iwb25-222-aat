# Subject Service API Test Script
# This script tests all the subject service endpoints

# Configuration
$baseUrl = "http://localhost:8080/api/subject"
$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "Starting Subject Service API Tests..." -ForegroundColor Green

# Test data
$testUserId = 1  # Assuming user with ID 1 is an officer
$testSubjectName = "Computer Science"
$testSubjectWeight = 8.5
$testSubjectId = $null

# Test 1: Add Subject
Write-Host "`n1. Testing Add Subject..." -ForegroundColor Yellow
$addSubjectData = @{
    name = $testSubjectName
    weight = $testSubjectWeight
    user_id = $testUserId
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method POST -Body $addSubjectData -Headers $headers
    Write-Host "✅ Add Subject: SUCCESS" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)"
    $testSubjectId = $response.data.subject_id
    Write-Host "Created Subject ID: $testSubjectId"
} catch {
    Write-Host "❌ Add Subject: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Test 2: Get All Subjects
Write-Host "`n2. Testing Get All Subjects..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method GET -Headers $headers
    Write-Host "✅ Get All Subjects: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) subjects"
} catch {
    Write-Host "❌ Get All Subjects: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Test 3: Get Subject by ID
if ($testSubjectId) {
    Write-Host "`n3. Testing Get Subject by ID..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId" -Method GET -Headers $headers
        Write-Host "✅ Get Subject by ID: SUCCESS" -ForegroundColor Green
        Write-Host "Subject Name: $($response.data.name)"
        Write-Host "Subject Weight: $($response.data.weight)"
    } catch {
        Write-Host "❌ Get Subject by ID: FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Test 4: Update Subject
if ($testSubjectId) {
    Write-Host "`n4. Testing Update Subject..." -ForegroundColor Yellow
    $updateSubjectData = @{
        name = "Advanced Computer Science"
        weight = 9.0
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId" -Method PUT -Body $updateSubjectData -Headers $headers
        Write-Host "✅ Update Subject: SUCCESS" -ForegroundColor Green
        Write-Host "Updated Name: $($response.data.name)"
        Write-Host "Updated Weight: $($response.data.weight)"
    } catch {
        Write-Host "❌ Update Subject: FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Test 5: Search Subjects by Name
Write-Host "`n5. Testing Search Subjects by Name..." -ForegroundColor Yellow
try {
    $searchName = "Computer"
    $response = Invoke-RestMethod -Uri "$baseUrl/search/$searchName" -Method GET -Headers $headers
    Write-Host "✅ Search Subjects: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) subjects matching '$searchName'"
} catch {
    Write-Host "❌ Search Subjects: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Test 6: Soft Delete Subject
if ($testSubjectId) {
    Write-Host "`n6. Testing Soft Delete Subject..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId" -Method DELETE -Headers $headers
        Write-Host "✅ Soft Delete Subject: SUCCESS" -ForegroundColor Green
        Write-Host "Deleted Subject ID: $($response.subject_id)"
    } catch {
        Write-Host "❌ Soft Delete Subject: FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Test 7: Get Deleted Subjects
Write-Host "`n7. Testing Get Deleted Subjects..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/deleted" -Method GET -Headers $headers
    Write-Host "✅ Get Deleted Subjects: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.data.Count) deleted subjects"
} catch {
    Write-Host "❌ Get Deleted Subjects: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Test 8: Restore Subject
if ($testSubjectId) {
    Write-Host "`n8. Testing Restore Subject..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId/restore" -Method POST -Headers $headers
        Write-Host "✅ Restore Subject: SUCCESS" -ForegroundColor Green
        Write-Host "Restored Subject: $($response.data.name)"
    } catch {
        Write-Host "❌ Restore Subject: FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Test 9: Verify Restored Subject
if ($testSubjectId) {
    Write-Host "`n9. Testing Get Restored Subject..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId" -Method GET -Headers $headers
        Write-Host "✅ Get Restored Subject: SUCCESS" -ForegroundColor Green
        Write-Host "Subject is accessible after restoration"
    } catch {
        Write-Host "❌ Get Restored Subject: FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Test 10: Test Invalid Weight (should fail)
Write-Host "`n10. Testing Add Subject with Invalid Weight..." -ForegroundColor Yellow
$invalidWeightData = @{
    name = "Invalid Subject"
    weight = 15.0  # Invalid weight > 10
    user_id = $testUserId
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method POST -Body $invalidWeightData -Headers $headers
    Write-Host "❌ Invalid Weight Test: FAILED (should have been rejected)" -ForegroundColor Red
} catch {
    Write-Host "✅ Invalid Weight Test: SUCCESS (correctly rejected)" -ForegroundColor Green
    Write-Host "Error message: $($_.Exception.Message)"
}

# Cleanup - Delete test subject
if ($testSubjectId) {
    Write-Host "`n11. Cleanup - Deleting Test Subject..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$testSubjectId" -Method DELETE -Headers $headers
        Write-Host "✅ Cleanup: SUCCESS" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Cleanup: Could not delete test subject" -ForegroundColor Yellow
    }
}

Write-Host "`nSubject Service API Tests Completed!" -ForegroundColor Green
