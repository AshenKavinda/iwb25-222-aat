import ballerina/http;

// Authentication REST API service
public service class AuthRestService {
    *http:Service;
    
    // POST /login - Login endpoint for all users
    resource function post login(@http:Payload LoginRequest loginReq) 
            returns LoginResponse|ErrorResponse|http:BadRequest|http:InternalServerError {
        
        LoginResponse|ErrorResponse result = login(loginReq);
        
        if result is ErrorResponse {
            if result.'error == "VALIDATION_ERROR" || result.'error == "AUTHENTICATION_ERROR" {
                return http:BAD_REQUEST;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }

    // POST /register - Registration endpoint for guest users only
    resource function post register(@http:Payload RegisterRequest registerReq) 
            returns LoginResponse|ErrorResponse|http:BadRequest|http:Conflict|http:InternalServerError {
        
        LoginResponse|ErrorResponse result = register(registerReq);
        
        if result is ErrorResponse {
            if result.'error == "VALIDATION_ERROR" {
                return http:BAD_REQUEST;
            }
            if result.'error == "EMAIL_EXISTS" {
                return http:CONFLICT;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }

    // POST /refresh - Refresh token endpoint
    resource function post refresh(@http:Payload RefreshTokenRequest refreshReq) 
            returns RefreshResponse|ErrorResponse|http:BadRequest|http:Unauthorized|http:InternalServerError {
        
        RefreshResponse|ErrorResponse result = refreshToken(refreshReq);
        
        if result is ErrorResponse {
            if result.'error == "VALIDATION_ERROR" {
                return http:BAD_REQUEST;
            }
            if result.'error == "INVALID_TOKEN" || result.'error == "USER_NOT_FOUND" {
                return http:UNAUTHORIZED;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }

    // GET /me - Get current user profile (requires authentication)
    resource function get me(@http:Header string? authorization) 
            returns UserWithProfile|ErrorResponse|http:Unauthorized|http:InternalServerError {
        
        if authorization is () {
            return <ErrorResponse>{
                message: "Authorization header is required",
                'error: "UNAUTHORIZED"
            };
        }
        
        UserWithProfile|ErrorResponse result = getCurrentUserWithProfile(authorization);
        
        if result is ErrorResponse {
            if result.'error == "INVALID_TOKEN" || result.'error == "USER_NOT_FOUND" {
                return http:UNAUTHORIZED;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }

    // POST /validate - Validate token endpoint
    resource function post validate(@http:Header string? authorization) 
            returns JwtPayload|ErrorResponse|http:Unauthorized|http:InternalServerError {
        
        if authorization is () {
            return <ErrorResponse>{
                message: "Authorization header is required",
                'error: "UNAUTHORIZED"
            };
        }
        
        JwtPayload|ErrorResponse result = validateToken(authorization);
        
        if result is ErrorResponse {
            if result.'error == "INVALID_TOKEN" || result.'error == "USER_NOT_FOUND" {
                return http:UNAUTHORIZED;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
}

// Health check service
public service class HealthService {
    *http:Service;
    
    // GET /health - Health check
    resource function get health() returns map<string> {
        return {
            "status": "healthy",
            "service": "School Performance Panel Authentication API",
            "timestamp": "2025-08-23T00:00:00Z"
        };
    }
}

// Function to create and return the authentication service
public isolated function getAuthService() returns AuthRestService {
    return new AuthRestService();
}

// Function to create and return the health service
public isolated function getHealthService() returns HealthService {
    return new HealthService();
}
