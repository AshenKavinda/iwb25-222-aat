# Test script for Test Enrollment Service
# This script tests the add and delete functionality of the test enrollment service

$baseUrl = "http://localhost:8080/api/test-enrollment"

Write-Host "Testing Test Enrollment Service" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Test data
$addTestEnrollmentData = @{
    "course_id" = 1
    "test_ids" = @(1, 2)
    "user_id" = 1
} | ConvertTo-Json

$deleteTestEnrollmentData = @{
    "course_id" = 1
    "test_ids" = @(1, 2)
    "user_id" = 1
} | ConvertTo-Json

$updateMarkData = @{
    "mark" = 85.5
    "user_id" = 1
} | ConvertTo-Json

Write-Host ""
Write-Host "1. Testing Add Test Enrollments (POST /api/test-enrollment)" -ForegroundColor Yellow
Write-Host "Request Body: $addTestEnrollmentData" -ForegroundColor Cyan

try {
    $addResponse = Invoke-RestMethod -Uri $baseUrl -Method POST -Body $addTestEnrollmentData -ContentType "application/json"
    Write-Host "Response:" -ForegroundColor Green
    $addResponse | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Delete Test Enrollments (DELETE /api/test-enrollment)" -ForegroundColor Yellow
Write-Host "Request Body: $deleteTestEnrollmentData" -ForegroundColor Cyan

try {
    $deleteResponse = Invoke-RestMethod -Uri $baseUrl -Method DELETE -Body $deleteTestEnrollmentData -ContentType "application/json"
    Write-Host "Response:" -ForegroundColor Green
    $deleteResponse | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing Get Test Enrollments by Course and Test (GET /api/test-enrollment/course/1/test/1)" -ForegroundColor Yellow

try {
    $getResponse = Invoke-RestMethod -Uri "$baseUrl/course/1/test/1" -Method GET
    Write-Host "Response:" -ForegroundColor Green
    $getResponse | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Testing Update Mark by Record ID (PUT /api/test-enrollment/1/mark)" -ForegroundColor Yellow
Write-Host "Request Body: $updateMarkData" -ForegroundColor Cyan

try {
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/1/mark" -Method PUT -Body $updateMarkData -ContentType "application/json"
    Write-Host "Response:" -ForegroundColor Green
    $updateResponse | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Green
