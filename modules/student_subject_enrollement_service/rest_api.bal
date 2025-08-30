import ballerina/http;
import school_performance_panel.authentication_service as auth;

// Student Subject Enrollment REST API service
public service class StudentSubjectEnrollmentRestService {
    *http:Service;

    // Add common subjects to all students in course - Only accessible by officer
    resource function post common(@http:Payload AddCommonSubjectsRequest addCommonSubjectsReq, @http:Header string? authorization) 
            returns AddCommonSubjectsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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
        if addCommonSubjectsReq.subject_ids.length() == 0 {
            return <http:BadRequest>{
                body: {
                    message: "Subject IDs array cannot be empty",
                    'error: "INVALID_PAYLOAD"
                }
            };
        }

        if addCommonSubjectsReq.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        if addCommonSubjectsReq.user_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid user ID",
                    'error: "INVALID_USER_ID"
                }
            };
        }

        // Validate all subject IDs are positive
        foreach int subjectId in addCommonSubjectsReq.subject_ids {
            if subjectId <= 0 {
                return <http:BadRequest>{
                    body: {
                        message: "Invalid subject ID: " + subjectId.toString(),
                        'error: "INVALID_SUBJECT_ID"
                    }
                };
            }
        }

        // Proceed with adding common subjects if authorization checks pass
        AddCommonSubjectsResponse|ErrorResponse|error result = addCommonSubjectsToCourse(addCommonSubjectsReq);

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

    // Add subjects to specific student - Only accessible by officer
    resource function post student(@http:Payload AddSubjectsToStudentRequest addSubjectsToStudentReq, @http:Header string? authorization) 
            returns AddSubjectsToStudentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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
        if addSubjectsToStudentReq.subject_ids.length() == 0 {
            return <http:BadRequest>{
                body: {
                    message: "Subject IDs array cannot be empty",
                    'error: "INVALID_PAYLOAD"
                }
            };
        }

        if addSubjectsToStudentReq.student_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        if addSubjectsToStudentReq.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        if addSubjectsToStudentReq.user_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid user ID",
                    'error: "INVALID_USER_ID"
                }
            };
        }

        // Validate all subject IDs are positive
        foreach int subjectId in addSubjectsToStudentReq.subject_ids {
            if subjectId <= 0 {
                return <http:BadRequest>{
                    body: {
                        message: "Invalid subject ID: " + subjectId.toString(),
                        'error: "INVALID_SUBJECT_ID"
                    }
                };
            }
        }

        // Proceed with adding subjects to student if authorization checks pass
        AddSubjectsToStudentResponse|ErrorResponse|error result = addSubjectsToStudent(addSubjectsToStudentReq);

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

    // Update student subject enrollment record by record ID - Only accessible by officer
    resource function put [int recordId](@http:Payload UpdateStudentSubjectEnrollmentRequest updateStudentSubjectEnrollmentReq, @http:Header string? authorization) 
            returns UpdateStudentSubjectEnrollmentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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
        if updateStudentSubjectEnrollmentReq?.student_id is () && updateStudentSubjectEnrollmentReq?.subject_id is () && updateStudentSubjectEnrollmentReq?.course_id is () {
            return <http:BadRequest>{
                body: {
                    message: "At least one field (student_id, subject_id, or course_id) must be provided for update",
                    'error: "NO_FIELDS_TO_UPDATE"
                }
            };
        }

        // Validate student ID if provided
        if updateStudentSubjectEnrollmentReq?.student_id is int && updateStudentSubjectEnrollmentReq?.student_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        // Validate subject ID if provided
        if updateStudentSubjectEnrollmentReq?.subject_id is int && updateStudentSubjectEnrollmentReq?.subject_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid subject ID",
                    'error: "INVALID_SUBJECT_ID"
                }
            };
        }

        // Validate course ID if provided
        if updateStudentSubjectEnrollmentReq?.course_id is int && updateStudentSubjectEnrollmentReq?.course_id <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        // Proceed with updating student subject enrollment record if authorization checks pass
        UpdateStudentSubjectEnrollmentResponse|ErrorResponse|error result = updateStudentSubjectEnrollment(recordId, updateStudentSubjectEnrollmentReq);

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

    // Delete student subject enrollment record by record ID (hard delete) - Only accessible by officer
    resource function delete [int recordId](@http:Header string? authorization) 
            returns DeleteStudentSubjectEnrollmentResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with deleting student subject enrollment record if authorization checks pass
        DeleteStudentSubjectEnrollmentResponse|ErrorResponse|error result = deleteStudentSubjectEnrollment(recordId);

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

    // Get student subject enrollment by record ID - Only accessible by officer
    resource function get [int recordId](@http:Header string? authorization) 
            returns GetStudentSubjectEnrollmentByIdResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Proceed with getting student subject enrollment by record ID if authorization checks pass
        GetStudentSubjectEnrollmentByIdResponse|ErrorResponse|error result = getStudentSubjectEnrollmentById(recordId);

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

    // Get all student subject enrollments with subject details by student ID and course ID - Only accessible by officer
    resource function get student/[int studentId]/course/[int courseId](@http:Header string? authorization) 
            returns GetStudentSubjectEnrollmentsWithDetailsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
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

        // Validate course ID
        if courseId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid course ID",
                    'error: "INVALID_COURSE_ID"
                }
            };
        }

        // Proceed with getting student subject enrollments with details if authorization checks pass
        GetStudentSubjectEnrollmentsWithDetailsResponse|ErrorResponse|error result = getStudentSubjectEnrollmentsWithDetails(studentId, courseId);

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

// Function to create and return the student subject enrollment service
public isolated function getStudentSubjectEnrollmentService() returns StudentSubjectEnrollmentRestService {
    return new StudentSubjectEnrollmentRestService();
}
