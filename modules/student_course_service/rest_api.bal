import ballerina/http;
import school_performance_panel.authentication_service as auth;

// Student Course REST API service
public service class StudentCourseRestService {
    *http:Service;

    // Add students to course (bulk insertion) - Only accessible by officer
    resource function post .(@http:Payload AddStudentsToCourseRequest addStudentsToCourseReq, @http:Header string? authorization) 
            returns AddStudentsToCourseResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate request payload
        if addStudentsToCourseReq.student_ids.length() == 0 {
            return <http:BadRequest>{
                body: {
                    message: "Student IDs array cannot be empty",
                    'error: "INVALID_PAYLOAD"
                }
            };
        }

        if addStudentsToCourseReq.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        if addStudentsToCourseReq.user_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid user ID",
                    'error: "INVALID_USER_ID"
                }
            };
        }

        // Validate all student IDs are positive
        foreach int studentId in addStudentsToCourseReq.student_ids {
            if studentId <= 0 {
                return <http:BadRequest>{
                    body: {
                        message: "Invalid student ID: " + studentId.toString(),
                        'error: "INVALID_STUDENT_ID"
                    }
                };
            }
        }

        // Proceed with adding students to course if authorization checks pass
        AddStudentsToCourseResponse|ErrorResponse|error result = addStudentsToCourse(addStudentsToCourseReq);

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

    // Update student course record by record ID - Only accessible by officer
    resource function put [int recordId](@http:Payload UpdateStudentCourseRequest updateStudentCourseReq, @http:Header string? authorization) 
            returns UpdateStudentCourseResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate record ID
        if recordId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid record ID",
                    'error: "INVALID_RECORD_ID"
                }
            };
        }

        // Validate request payload - at least one field should be provided
        if updateStudentCourseReq?.student_id is () && updateStudentCourseReq?.course_id is () {
            return <http:BadRequest>{
                body: {
                    message: "At least one field (student_id or course_id) must be provided for update",
                    'error: "NO_FIELDS_TO_UPDATE"
                }
            };
        }

        // Validate student ID if provided
        if updateStudentCourseReq?.student_id is int && updateStudentCourseReq?.student_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        // Validate course ID if provided
        if updateStudentCourseReq?.course_id is int && updateStudentCourseReq?.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        // Proceed with updating student course record if authorization checks pass
        UpdateStudentCourseResponse|ErrorResponse|error result = updateStudentCourse(recordId, updateStudentCourseReq);

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

    // Delete student course record by record ID (hard delete) - Only accessible by officer
    resource function delete [int recordId](@http:Header string? authorization) 
            returns DeleteStudentCourseResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate record ID
        if recordId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid record ID",
                    'error: "INVALID_RECORD_ID"
                }
            };
        }

        // Proceed with deleting student course record if authorization checks pass
        DeleteStudentCourseResponse|ErrorResponse|error result = deleteStudentCourse(recordId);

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

    // Get student course by record ID - Only accessible by officer
    resource function get [int recordId](@http:Header string? authorization) 
            returns GetStudentCourseByIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate record ID
        if recordId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid record ID",
                    'error: "INVALID_RECORD_ID"
                }
            };
        }

        // Proceed with getting student course by record ID if authorization checks pass
        GetStudentCourseByIdResponse|ErrorResponse|error result = getStudentCourseById(recordId);

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

    // Get all student courses by student ID - Only accessible by officer
    resource function get student/[int studentId](@http:Header string? authorization) 
            returns GetStudentCoursesByStudentIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate student ID
        if studentId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        // Proceed with getting student courses by student ID if authorization checks pass
        GetStudentCoursesByStudentIdResponse|ErrorResponse|error result = getStudentCoursesByStudentId(studentId);

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

    // Get all student courses by course ID - Only accessible by officer
    resource function get course/[int courseId](@http:Header string? authorization) 
            returns GetStudentCoursesByCourseIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate course ID
        if courseId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        // Proceed with getting student courses by course ID if authorization checks pass
        GetStudentCoursesByCourseIdResponse|ErrorResponse|error result = getStudentCoursesByCourseId(courseId);

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

    // Get student courses with details by student ID - Only accessible by officer
    resource function get student/[int studentId]/details(@http:Header string? authorization) 
            returns GetStudentCoursesWithDetailsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate student ID
        if studentId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        // Proceed with getting student courses with details by student ID if authorization checks pass
        GetStudentCoursesWithDetailsResponse|ErrorResponse|error result = getStudentCoursesWithDetailsByStudentId(studentId);

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

    // Get student courses with details by course ID - Only accessible by officer
    resource function get course/[int courseId]/details(@http:Header string? authorization) 
            returns GetStudentCoursesWithDetailsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate course ID
        if courseId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        // Proceed with getting student courses with details by course ID if authorization checks pass
        GetStudentCoursesWithDetailsResponse|ErrorResponse|error result = getStudentCoursesWithDetailsByCourseId(courseId);

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

// Function to create and return the student course service
public isolated function getStudentCourseService() returns StudentCourseRestService {
    return new StudentCourseRestService();
}
