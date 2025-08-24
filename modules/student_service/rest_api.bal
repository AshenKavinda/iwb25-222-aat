import ballerina/http;
import school_performance_panel.authentication_service as auth;

// Student REST API service
public service class StudentRestService {
    *http:Service;

    // Add student - Only accessible by officer
    resource function post .(@http:Payload AddStudentRequest addStudentReq, @http:Header string? authorization) 
            returns AddStudentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with adding student if authorization checks pass
        AddStudentResponse|ErrorResponse|error result = addStudent(addStudentReq);

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

    // Update student - Only accessible by officer
    resource function put [int studentId](@http:Payload UpdateStudentRequest updateStudentReq, @http:Header string? authorization) 
            returns UpdateStudentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with updating student if authorization checks pass
        UpdateStudentResponse|ErrorResponse|error result = updateStudent(studentId, updateStudentReq);

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

    // Soft delete student - Only accessible by officer
    resource function delete [int studentId](@http:Header string? authorization) 
            returns DeleteStudentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with soft deleting student if authorization checks pass
        DeleteStudentResponse|ErrorResponse|error result = softDeleteStudent(studentId);

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

    // Restore student - Only accessible by officer
    resource function post [int studentId]/restore(@http:Header string? authorization) 
            returns RestoreStudentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with restoring student if authorization checks pass
        RestoreStudentResponse|ErrorResponse|error result = restoreStudent(studentId);

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

    // Get all students - Only accessible by officer
    resource function get .(@http:Header string? authorization) 
            returns GetAllStudentsResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with getting all students if authorization checks pass
        GetAllStudentsResponse|ErrorResponse|error result = getAllStudents();

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

    // Get student by ID - Only accessible by officer
    resource function get [int studentId](@http:Header string? authorization) 
            returns GetStudentByIdResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with getting student by ID if authorization checks pass
        GetStudentByIdResponse|ErrorResponse|error result = getStudentById(studentId);

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

    // Get deleted students - Only accessible by officer
    resource function get deleted(@http:Header string? authorization) 
            returns GetDeletedStudentsResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with getting deleted students if authorization checks pass
        GetDeletedStudentsResponse|ErrorResponse|error result = getDeletedStudents();

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

    // Search students by full name - Only accessible by officer
    resource function get search(string name, @http:Header string? authorization) 
            returns SearchStudentsByNameResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate name parameter
        if name.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Name parameter is required and cannot be empty",
                    'error: "INVALID_PARAMETER"
                }
            };
        }

        // Proceed with searching students by name if authorization checks pass
        SearchStudentsByNameResponse|ErrorResponse|error result = searchStudentsByName(name);

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

// Function to create and return the student service
public isolated function getStudentService() returns StudentRestService {
    return new StudentRestService();
}
