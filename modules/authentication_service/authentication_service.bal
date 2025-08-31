import ballerina/log;
import ballerina/regex;

// Authentication service class
public isolated class AuthenticationService {
    
    // Login endpoint - supports all user roles
    public isolated function login(LoginRequest loginReq) returns LoginResponse|ErrorResponse {
        do {
            // Validate input
            if loginReq.email.trim() == "" || loginReq.password.trim() == "" {
                return {
                    message: "Email and password are required",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Validate email format
            if !self.isValidEmail(loginReq.email) {
                return {
                    message: "Invalid email format",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Get user from database
            User? user = check dbConnection.getUserByEmail(loginReq.email);
            if user is () {
                return {
                    message: "Invalid email or password",
                    'error: "AUTHENTICATION_ERROR"
                };
            }

            // Verify password
            boolean isValidPassword = check dbConnection.verifyPassword(loginReq.password, user.password ?: "");
            if !isValidPassword {
                return {
                    message: "Invalid email or password",
                    'error: "AUTHENTICATION_ERROR"
                };
            }

            // Generate tokens
            string accessToken = check jwtUtils.generateAccessToken(user);
            string refreshToken = check jwtUtils.generateRefreshToken(user);

            // Remove password from response
            User userResponse = {
                user_id: user.user_id,
                email: user.email,
                role: user.role,
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            return {
                access_token: accessToken,
                refresh_token: refreshToken,
                user: userResponse,
                message: "Login successful"
            };

        } on fail error e {
            log:printError("Login error", 'error = e);
            return {
                message: "Internal server error",
                'error: "INTERNAL_ERROR"
            };
        }
    }

    // Register endpoint - only for guest users
    public isolated function register(RegisterRequest registerReq) returns LoginResponse|ErrorResponse {
        do {
            // Validate input
            if registerReq.email.trim() == "" || registerReq.password.trim() == "" || registerReq.name.trim() == "" {
                return {
                    message: "Email, password, and name are required",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Validate email format
            if !self.isValidEmail(registerReq.email) {
                return {
                    message: "Invalid email format",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Validate password strength
            if !self.isValidPassword(registerReq.password) {
                return {
                    message: "Password must be at least 8 characters long and contain at least one letter and one number",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Check if email already exists
            boolean emailExists = check dbConnection.emailExists(registerReq.email);
            if emailExists {
                return {
                    message: "Email already exists",
                    'error: "EMAIL_EXISTS"
                };
            }

            // Create user with guest role
            User newUser = check dbConnection.createUser(registerReq.email, registerReq.password, GUEST);

            // Create profile
            Profile _ = check dbConnection.createProfile(
                registerReq.name,
                registerReq?.phone_number,
                registerReq?.dob,
                newUser.user_id ?: 0
            );

            // Generate tokens
            string accessToken = check jwtUtils.generateAccessToken(newUser);
            string refreshToken = check jwtUtils.generateRefreshToken(newUser);

            // Remove password from response
            User userResponse = {
                user_id: newUser.user_id,
                email: newUser.email,
                role: newUser.role,
                created_at: newUser.created_at,
                updated_at: newUser.updated_at
            };

            return {
                access_token: accessToken,
                refresh_token: refreshToken,
                user: userResponse,
                message: "Registration successful"
            };

        } on fail error e {
            log:printError("Registration error", 'error = e);
            return {
                message: "Internal server error",
                'error: "INTERNAL_ERROR"
            };
        }
    }

    // Refresh token endpoint
    public isolated function refreshToken(RefreshTokenRequest refreshReq) returns RefreshResponse|ErrorResponse {
        do {
            // Validate input
            if refreshReq.refresh_token.trim() == "" {
                return {
                    message: "Refresh token is required",
                    'error: "VALIDATION_ERROR"
                };
            }

            // Validate refresh token
            JwtPayload payload = check jwtUtils.validateRefreshToken(refreshReq.refresh_token);

            // Get user from database to ensure user still exists
            User? user = check dbConnection.getUserById(payload.user_id);
            if user is () {
                return {
                    message: "User not found",
                    'error: "USER_NOT_FOUND"
                };
            }

            // Generate new access token
            string newAccessToken = check jwtUtils.generateAccessToken(user);

            return {
                access_token: newAccessToken,
                message: "Token refreshed successfully"
            };

        } on fail error e {
            log:printError("Refresh token error", 'error = e);
            return {
                message: "Invalid or expired refresh token",
                'error: "INVALID_TOKEN"
            };
        }
    }

    // Validate access token and return user info
    public isolated function validateToken(string authHeader) returns JwtPayload|ErrorResponse {
        do {
            // Extract token from header
            string token = check jwtUtils.extractTokenFromHeader(authHeader);

            // Validate token
            JwtPayload payload = check jwtUtils.validateAccessToken(token);

            // Verify user still exists in database
            User? user = check dbConnection.getUserById(payload.user_id);
            if user is () {
                return {
                    message: "User not found",
                    'error: "USER_NOT_FOUND"
                };
            }

            return payload;

        } on fail error e {
            log:printError("Token validation error", 'error = e);
            return {
                message: "Invalid or expired token",
                'error: "INVALID_TOKEN"
            };
        }
    }

    // Get current user profile
    public isolated function getCurrentUser(string authHeader) returns User|ErrorResponse {
        do {
            // Validate token first
            JwtPayload|ErrorResponse tokenResult = self.validateToken(authHeader);
            if tokenResult is ErrorResponse {
                return tokenResult;
            }

            JwtPayload payload = <JwtPayload>tokenResult;

            // Get user from database
            User? user = check dbConnection.getUserById(payload.user_id);
            if user is () {
                return {
                    message: "User not found",
                    'error: "USER_NOT_FOUND"
                };
            }

            // Remove password from response
            User userResponse = {
                user_id: user.user_id,
                email: user.email,
                role: user.role,
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            return userResponse;

        } on fail error e {
            log:printError("Get current user error", 'error = e);
            return {
                message: "Internal server error",
                'error: "INTERNAL_ERROR"
            };
        }
    }

    // Get current user with profile data
    public isolated function getCurrentUserWithProfile(string authHeader) returns UserWithProfile|ErrorResponse {
        do {
            // Validate token first
            JwtPayload|ErrorResponse tokenResult = self.validateToken(authHeader);
            if tokenResult is ErrorResponse {
                return tokenResult;
            }

            JwtPayload payload = <JwtPayload>tokenResult;

            // Get user from database
            User? user = check dbConnection.getUserById(payload.user_id);
            if user is () {
                return {
                    message: "User not found",
                    'error: "USER_NOT_FOUND"
                };
            }

            // Remove password from user response
            User userResponse = {
                user_id: user.user_id,
                email: user.email,
                role: user.role,
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            // Get profile data
            Profile? profile = check dbConnection.getProfileByUserId(payload.user_id);

            return {
                user: userResponse,
                profile: profile
            };

        } on fail error e {
            log:printError("Get current user with profile error", 'error = e);
            return {
                message: "Internal server error",
                'error: "INTERNAL_ERROR"
            };
        }
    }

    // Helper method to validate email format
    private isolated function isValidEmail(string email) returns boolean {
        string emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return regex:matches(email, emailPattern);
    }

    // Helper method to validate password strength
    private isolated function isValidPassword(string password) returns boolean {
        if password.length() < 8 {
            return false;
        }
        // Check for at least one letter and one number
        boolean hasLetter = regex:matches(password, ".*[a-zA-Z].*");
        boolean hasNumber = regex:matches(password, ".*[0-9].*");
        return hasLetter && hasNumber;
    }

    // Authorization helper - check if user has required role
    public isolated function hasRole(string authHeader, UserRole requiredRole) returns boolean|ErrorResponse {
        JwtPayload|ErrorResponse tokenResult = self.validateToken(authHeader);
        if tokenResult is ErrorResponse {
            return tokenResult;
        }

        JwtPayload payload = <JwtPayload>tokenResult;
        return payload.role == requiredRole;
    }

    // Authorization helper - check if user has any of the required roles
    public isolated function hasAnyRole(string authHeader, UserRole[] requiredRoles) returns boolean|ErrorResponse {
        JwtPayload|ErrorResponse tokenResult = self.validateToken(authHeader);
        if tokenResult is ErrorResponse {
            return tokenResult;
        }

        JwtPayload payload = <JwtPayload>tokenResult;
        foreach UserRole role in requiredRoles {
            if payload.role == role {
                return true;
            }
        }
        return false;
    }
}

// Global authentication service instance
final AuthenticationService authService = new AuthenticationService();

// Public functions to expose service functionality

public isolated function login(LoginRequest loginReq) returns LoginResponse|ErrorResponse {
    return authService.login(loginReq);
}

public isolated function register(RegisterRequest registerReq) returns LoginResponse|ErrorResponse {
    return authService.register(registerReq);
}

public isolated function refreshToken(RefreshTokenRequest refreshReq) returns RefreshResponse|ErrorResponse {
    return authService.refreshToken(refreshReq);
}

public isolated function validateToken(string authHeader) returns JwtPayload|ErrorResponse {
    return authService.validateToken(authHeader);
}

public isolated function getCurrentUser(string authHeader) returns User|ErrorResponse {
    return authService.getCurrentUser(authHeader);
}

public isolated function getCurrentUserWithProfile(string authHeader) returns UserWithProfile|ErrorResponse {
    return authService.getCurrentUserWithProfile(authHeader);
}

public isolated function hasRole(string authHeader, UserRole requiredRole) returns boolean|ErrorResponse {
    return authService.hasRole(authHeader, requiredRole);
}

public isolated function hasAnyRole(string authHeader, UserRole[] requiredRoles) returns boolean|ErrorResponse {
    return authService.hasAnyRole(authHeader, requiredRoles);
}
