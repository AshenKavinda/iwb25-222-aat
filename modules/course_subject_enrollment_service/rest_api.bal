import ballerina/http;
import school_performance_panel.authentication_service as auth;

// Course Subject Enrollment REST API service
public service class CourseSubjectEnrollmentRestService {
    *http:Service;

    // Add course subject enrollment - Only accessible by officer
    resource function post .(@http:Payload AddCourseSubjectEnrollmentRequest addCourseSubjectEnrollmentReq, @http:Header string? authorization) 
            returns AddCourseSubjectEnrollmentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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
        if addCourseSubjectEnrollmentReq.subject_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid subject ID",
                    'error: "INVALID_SUBJECT_ID"
                }
            };
        }

        if addCourseSubjectEnrollmentReq.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        if addCourseSubjectEnrollmentReq.teacher_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid teacher ID",
                    'error: "INVALID_TEACHER_ID"
                }
            };
        }

        if addCourseSubjectEnrollmentReq.user_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid user ID",
                    'error: "INVALID_USER_ID"
                }
            };
        }

        // Proceed with adding course subject enrollment if authorization checks pass
        AddCourseSubjectEnrollmentResponse|ErrorResponse|error result = addCourseSubjectEnrollment(addCourseSubjectEnrollmentReq);

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

    // Update course subject enrollment record by record ID (only subject_id field) - Only accessible by officer
    resource function put [int recordId](@http:Payload UpdateCourseSubjectEnrollmentRequest updateCourseSubjectEnrollmentReq, @http:Header string? authorization) 
            returns UpdateCourseSubjectEnrollmentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate subject ID
        if updateCourseSubjectEnrollmentReq.subject_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid subject ID",
                    'error: "INVALID_SUBJECT_ID"
                }
            };
        }

        // Proceed with updating course subject enrollment record if authorization checks pass
        UpdateCourseSubjectEnrollmentResponse|ErrorResponse|error result = updateCourseSubjectEnrollment(recordId, updateCourseSubjectEnrollmentReq);

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

    // Delete course subject enrollment record by record ID (hard delete) - Only accessible by officer
    resource function delete [int recordId](@http:Header string? authorization) 
            returns DeleteCourseSubjectEnrollmentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with deleting course subject enrollment record if authorization checks pass
        DeleteCourseSubjectEnrollmentResponse|ErrorResponse|error result = deleteCourseSubjectEnrollment(recordId);

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

    // Get all course subject enrollments by course ID - Only accessible by officer
    resource function get course/[int courseId](@http:Header string? authorization) 
            returns GetCourseSubjectEnrollmentsByCourseIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with getting course subject enrollments by course ID if authorization checks pass
        GetCourseSubjectEnrollmentsByCourseIdResponse|ErrorResponse|error result = getCourseSubjectEnrollmentsByCourseId(courseId);

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

    // Get all course subject enrollments by teacher ID with course details - Only accessible by officer
    resource function get teacher/[int teacherId](@http:Header string? authorization) 
            returns GetCourseSubjectEnrollmentsByTeacherIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate teacher ID
        if teacherId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid teacher ID",
                    'error: "INVALID_TEACHER_ID"
                }
            };
        }

        // Proceed with getting course subject enrollments by teacher ID if authorization checks pass
        GetCourseSubjectEnrollmentsByTeacherIdResponse|ErrorResponse|error result = getCourseSubjectEnrollmentsByTeacherId(teacherId);

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

// Function to create and return the course subject enrollment service
public isolated function getCourseSubjectEnrollmentService() returns CourseSubjectEnrollmentRestService {
    return new CourseSubjectEnrollmentRestService();
}
