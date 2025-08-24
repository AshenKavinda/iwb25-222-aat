import ballerina/http;
import school_performance_panel.authentication_service as auth;

// User REST API service
public service class UserRestService {
    *http:Service;

    // POST / - Add user with profile (Only for officers)
    resource function post .(@http:Payload AddUserRequest addUserReq, @http:Header string? authorization) 
            returns AddUserResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with adding user if authorization checks pass
        AddUserResponse|ErrorResponse|error result = addUserWithProfile(addUserReq);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // PUT /[int user_id] - Update user with profile (Only for officers and guests)
    resource function put [int user_id](@http:Payload UpdateUserRequest updateUserReq, @http:Header string? authorization) 
            returns UpdateUserResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with updating user if authorization checks pass
        UpdateUserResponse|ErrorResponse|error result = updateUserWithProfile(user_id, updateUserReq);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // DELETE /[int user_id] - Soft delete user (Only for officers and guests)
    resource function delete [int user_id](@http:Header string? authorization) 
            returns DeleteUserResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with soft deleting user if authorization checks pass
        DeleteUserResponse|ErrorResponse|error result = softDeleteUser(user_id);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // POST /[int user_id]/restore - Restore soft deleted user (Only for officers and guests)
    resource function post [int user_id]/restore(@http:Header string? authorization) 
            returns RestoreUserResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with restoring user if authorization checks pass
        RestoreUserResponse|ErrorResponse|error result = restoreUser(user_id);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // GET / - Get all active users (Only for officers and guests)
    resource function get .(@http:Header string? authorization) 
            returns GetAllUsersResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with getting all users if authorization checks pass
        GetAllUsersResponse|ErrorResponse|error result = getAllUsersWithProfiles();

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // GET /[int user_id] - Get user by ID (Only for officers and guests)
    resource function get [int user_id](@http:Header string? authorization) 
            returns GetUserByIdResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with getting user by ID if authorization checks pass
        GetUserByIdResponse|ErrorResponse|error result = getUserByIdWithProfile(user_id);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // GET /deleted - Get all deleted users (Only for officers and guests)
    resource function get deleted(@http:Header string? authorization) 
            returns GetDeletedUsersResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with getting deleted users if authorization checks pass
        GetDeletedUsersResponse|ErrorResponse|error result = getDeletedUsersWithProfiles();

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }

    // GET /search?email=<email_pattern> - Search users by email (Only for officers and guests)
    resource function get search(string email, @http:Header string? authorization) 
            returns SearchUsersByEmailResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is officer or guest
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "officer");
        
        if roleCheck is auth:ErrorResponse {
            return <http:Unauthorized>{
                body: {
                    message: roleCheck.message,
                    'error: roleCheck.'error
                }
            };
        }

        if roleCheck is boolean && !roleCheck {
            return <http:Forbidden>{
                body: {
                    message: "Access denied. Officer or Guest role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate email parameter
        if email.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Email parameter is required and cannot be empty",
                    'error: "INVALID_PARAMETER"
                }
            };
        }

        // Proceed with searching users by email if authorization checks pass
        SearchUsersByEmailResponse|ErrorResponse|error result = searchUsersByEmailWithProfiles(email);

        if result is ErrorResponse {
            return <http:InternalServerError>{
                body: result
            };
        }

        if result is error {
            return <http:InternalServerError>{
                body: {
                    message: "Internal server error",
                    'error: "INTERNAL_ERROR"
                }
            };
        }

        return result;
    }
}

// Function to create and return the user service
public isolated function getUserService() returns UserRestService {
    return new UserRestService();
}
