# Test script for soft delete and restore user APIs
# This script demonstrates how to use the DELETE and POST restore endpoints

# Base URL
$baseUrl = "http://localhost:8080/api"

# Function to test soft delete user
function Test-SoftDeleteUser {
    param(
        [string]$AccessToken,
        [int]$UserId
    )
    
    Write-Host "Testing Soft Delete User for User ID: $UserId" -ForegroundColor Yellow
    
    # Prepare headers
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $AccessToken"
    }
    
    try {
        # Make DELETE request to soft delete user
        $response = Invoke-RestMethod -Uri "$baseUrl/user/$UserId" -Method DELETE -Headers $headers
        Write-Host "✅ Soft delete successful!" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "❌ Soft delete failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorContent = $reader.ReadToEnd()
            Write-Host "Error Details: $errorContent" -ForegroundColor Red
        }
    }
}

# Function to test restore user
function Test-RestoreUser {
    param(
        [string]$AccessToken,
        [int]$UserId
    )
    
    Write-Host "Testing Restore User for User ID: $UserId" -ForegroundColor Yellow
    
    # Prepare headers
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $AccessToken"
    }
    
    try {
        # Make POST request to restore user
        $response = Invoke-RestMethod -Uri "$baseUrl/user/$UserId/restore" -Method POST -Headers $headers
        Write-Host "✅ Restore successful!" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "❌ Restore failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorContent = $reader.ReadToEnd()
            Write-Host "Error Details: $errorContent" -ForegroundColor Red
        }
    }
}

# Example usage scenarios
Write-Host "=== User Soft Delete and Restore API Test ===" -ForegroundColor Magenta
Write-Host ""

Write-Host "Example 1: Soft Delete a User" -ForegroundColor Blue
Write-Host "This will set deleted_at timestamp for both user and profile records" -ForegroundColor White
# Uncomment and run with actual token and user ID:
# Test-SoftDeleteUser -AccessToken "your-access-token-here" -UserId 1

Write-Host ""

Write-Host "Example 2: Restore a Deleted User" -ForegroundColor Blue
Write-Host "This will set deleted_at to NULL for both user and profile records" -ForegroundColor White
# Uncomment and run with actual token and user ID:
# Test-RestoreUser -AccessToken "your-access-token-here" -UserId 1

Write-Host ""

Write-Host "Example 3: Complete Workflow Test" -ForegroundColor Blue
Write-Host "Delete a user, then restore them back" -ForegroundColor White
function Test-CompleteWorkflow {
    param(
        [string]$AccessToken,
        [int]$UserId
    )
    
    Write-Host "Step 1: Soft deleting user..." -ForegroundColor Cyan
    Test-SoftDeleteUser -AccessToken $AccessToken -UserId $UserId
    
    Write-Host "`nStep 2: Waiting 2 seconds..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    
    Write-Host "Step 3: Restoring user..." -ForegroundColor Cyan
    Test-RestoreUser -AccessToken $AccessToken -UserId $UserId
}

# Uncomment and run with actual token and user ID:
# Test-CompleteWorkflow -AccessToken "your-access-token-here" -UserId 1

Write-Host ""
Write-Host "=== Instructions ===" -ForegroundColor Magenta
Write-Host "1. First login or register to get an access token" -ForegroundColor White
Write-Host "2. Replace 'your-access-token-here' with the actual token" -ForegroundColor White
Write-Host "3. Replace user ID with the actual user ID you want to test" -ForegroundColor White
Write-Host "4. Uncomment the test function call you want to run" -ForegroundColor White
Write-Host "5. Run the script" -ForegroundColor White
Write-Host ""
Write-Host "Role Requirements:" -ForegroundColor Yellow
Write-Host "  - Officer: Can delete/restore any user" -ForegroundColor White
Write-Host "  - Guest: Can delete/restore any user" -ForegroundColor White
Write-Host "  - Manager/Teacher: Cannot delete/restore users (will get 403 Forbidden)" -ForegroundColor White
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Green
Write-Host "  - DELETE /api/user/{user_id} - Soft delete user" -ForegroundColor White
Write-Host "  - POST /api/user/{user_id}/restore - Restore deleted user" -ForegroundColor White
Write-Host ""
Write-Host "How Soft Delete Works:" -ForegroundColor Cyan
Write-Host "  - Sets deleted_at timestamp in both user and profile tables" -ForegroundColor White
Write-Host "  - User data remains in database but marked as deleted" -ForegroundColor White
Write-Host "  - Can be restored by setting deleted_at back to NULL" -ForegroundColor White
Write-Host "  - Prevents data loss while allowing logical deletion" -ForegroundColor White
