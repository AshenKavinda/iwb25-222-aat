# Test script for updating user via API
# This script demonstrates how to use the PUT /api/user/{user_id} endpoint

# Base URL
$baseUrl = "http://localhost:8080/api"

# Function to test user update
function Test-UpdateUser {
    param(
        [string]$AccessToken,
        [int]$UserId,
        [hashtable]$UpdateData
    )
    
    Write-Host "Testing User Update for User ID: $UserId" -ForegroundColor Yellow
    
    # Prepare headers
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $AccessToken"
    }
    
    # Convert update data to JSON
    $jsonBody = $UpdateData | ConvertTo-Json -Depth 3
    Write-Host "Request Body: $jsonBody" -ForegroundColor Cyan
    
    try {
        # Make PUT request to update user
        $response = Invoke-RestMethod -Uri "$baseUrl/user/$UserId" -Method PUT -Headers $headers -Body $jsonBody
        Write-Host "✅ Update successful!" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "❌ Update failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorContent = $reader.ReadToEnd()
            Write-Host "Error Details: $errorContent" -ForegroundColor Red
        }
    }
}

# Example usage (replace with actual access token and user ID)
Write-Host "=== User Update API Test ===" -ForegroundColor Magenta
Write-Host ""

# Example 1: Update user profile (name and phone)
Write-Host "Example 1: Update profile information" -ForegroundColor Blue
$updateProfileData = @{
    name = "Updated User Name"
    phone_number = "+1234567890"
}

# Uncomment and run with actual token and user ID:
# Test-UpdateUser -AccessToken "your-access-token-here" -UserId 1 -UpdateData $updateProfileData

Write-Host ""

# Example 2: Update user role (officer only)
Write-Host "Example 2: Update user role (Officer role required)" -ForegroundColor Blue
$updateRoleData = @{
    role = "teacher"
}

# Uncomment and run with actual token and user ID:
# Test-UpdateUser -AccessToken "your-officer-access-token-here" -UserId 1 -UpdateData $updateRoleData

Write-Host ""

# Example 3: Update name and phone together
Write-Host "Example 3: Update name and phone together" -ForegroundColor Blue
$updateNamePhoneData = @{
    name = "John Doe Updated"
    phone_number = "+9876543210"
}

# Uncomment and run with actual token and user ID:
# Test-UpdateUser -AccessToken "your-access-token-here" -UserId 1 -UpdateData $updateNamePhoneData

Write-Host ""

# Example 4: Partial update (only date of birth)
Write-Host "Example 4: Partial update (date of birth only)" -ForegroundColor Blue
$updateDobData = @{
    dob = "1990-01-15"
}

# Uncomment and run with actual token and user ID:
# Test-UpdateUser -AccessToken "your-access-token-here" -UserId 1 -UpdateData $updateDobData

Write-Host ""
Write-Host "=== Instructions ===" -ForegroundColor Magenta
Write-Host "1. First login or register to get an access token" -ForegroundColor White
Write-Host "2. Replace 'your-access-token-here' with the actual token" -ForegroundColor White
Write-Host "3. Replace user ID with the actual user ID you want to update" -ForegroundColor White
Write-Host "4. Uncomment the Test-UpdateUser call you want to test" -ForegroundColor White
Write-Host "5. Run the script" -ForegroundColor White
Write-Host ""
Write-Host "Role Requirements:" -ForegroundColor Yellow
Write-Host "  - Officer: Can update any user" -ForegroundColor White
Write-Host "  - Guest: Can update any user" -ForegroundColor White
Write-Host "  - Manager/Teacher: Cannot update users (will get 403 Forbidden)" -ForegroundColor White
Write-Host ""
Write-Host "Update Restrictions:" -ForegroundColor Red
Write-Host "  - Email: Cannot be updated (security restriction)" -ForegroundColor White
Write-Host "  - Password: Cannot be updated (use separate password change endpoint)" -ForegroundColor White
Write-Host "  - Allowed: role, name, phone_number, dob" -ForegroundColor Green
