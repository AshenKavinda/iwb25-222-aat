import ballerina/test;
import ballerina/io;

// Test data
const string TEST_EMAIL = "test@example.com";
const string TEST_PASSWORD = "testpassword123";
const string TEST_NAME = "Test User";

// Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Starting Authentication Service Tests!");
}

// Test function for validation logic
@test:Config {}
function testRegisterRequestValidation() {
    RegisterRequest registerReq = {
        email: TEST_EMAIL,
        password: TEST_PASSWORD,
        name: TEST_NAME,
        phone_number: "1234567890",
        dob: "1990-01-01"
    };

    test:assertTrue(registerReq.email.length() > 0, "Email should not be empty");
    test:assertTrue(registerReq.password.length() >= 8, "Password should be at least 8 characters");
    test:assertTrue(registerReq.name.length() > 0, "Name should not be empty");
}

@test:Config {}
function testLoginRequestValidation() {
    LoginRequest loginReq = {
        email: TEST_EMAIL,
        password: TEST_PASSWORD
    };

    test:assertTrue(loginReq.email.length() > 0, "Email should not be empty");
    test:assertTrue(loginReq.password.length() > 0, "Password should not be empty");
}

@test:Config {}
function testRefreshTokenRequestValidation() {
    RefreshTokenRequest refreshReq = {
        refresh_token: "sample.refresh.token"
    };

    test:assertTrue(refreshReq.refresh_token.length() > 0, "Refresh token should not be empty");
}

// Test UserRole enum
@test:Config {}
function testUserRoles() {
    test:assertEquals(GUEST, "guest", "Guest role should be 'guest'");
    test:assertEquals(TEACHER, "teacher", "Teacher role should be 'teacher'");
    test:assertEquals(OFFICER, "officer", "Officer role should be 'officer'");
    test:assertEquals(MANAGER, "manager", "Manager role should be 'manager'");
}

// Example of how to test authentication service (requires database setup)
@test:Config {enable: false} // Disabled by default as it requires database
function testFullAuthenticationFlow() returns error? {
    // This test would require a test database setup
    // 1. Register a new guest user
    RegisterRequest registerReq = {
        email: "newuser@example.com",
        password: "securepassword123",
        name: "New User",
        phone_number: "9876543210"
    };

    LoginResponse|ErrorResponse registerResult = register(registerReq);
    test:assertTrue(registerResult is LoginResponse, "Registration should succeed");

    if registerResult is LoginResponse {
        // 2. Extract tokens
        string accessToken = registerResult.access_token;
        string refreshTokenStr = registerResult.refresh_token;
        
        // 3. Validate access token
        JwtPayload|ErrorResponse validateResult = validateToken("Bearer " + accessToken);
        test:assertTrue(validateResult is JwtPayload, "Token validation should succeed");

        // 4. Get current user
        User|ErrorResponse userResult = getCurrentUser("Bearer " + accessToken);
        test:assertTrue(userResult is User, "Get current user should succeed");

        // 5. Refresh token
        RefreshTokenRequest refreshReq = {
            refresh_token: refreshTokenStr
        };
        RefreshResponse|ErrorResponse refreshResult = refreshToken(refreshReq);
        test:assertTrue(refreshResult is RefreshResponse, "Token refresh should succeed");
    }
}

// After Suite Function
@test:AfterSuite
function afterSuiteFunc() {
    io:println("Authentication Service Tests Completed!");
}
