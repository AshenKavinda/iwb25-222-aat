import ballerina/http;
import school_performance_panel.authentication_service as auth;

// Report REST API service
public service class ReportRestService {
    *http:Service;

    // Get top performing students - Only accessible by manager
    resource function get topstudents(string year, string term_type, int? limitCount, @http:Header string? authorization) 
            returns TopPerformingStudentsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate required parameters
        if year.trim() == "" || term_type.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Year and term_type parameters are required",
                    'error: "INVALID_PARAMETERS"
                }
            };
        }

        // Validate term_type
        if term_type != "tm1" && term_type != "tm2" && term_type != "tm3" {
            return <http:BadRequest>{
                body: {
                    message: "Invalid term_type. Must be tm1, tm2, or tm3",
                    'error: "INVALID_TERM_TYPE"
                }
            };
        }

        // Proceed with getting top performing students if authorization checks pass
        TopPerformingStudentsResponse|ErrorResponse|error result = getTopPerformingStudents(year, term_type, limitCount);

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

    // Get average marks per subject - Only accessible by manager
    resource function get avgmarks(string year, string term_type, @http:Header string? authorization) 
            returns AverageMarksBySubjectResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate required parameters
        if year.trim() == "" || term_type.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Year and term_type parameters are required",
                    'error: "INVALID_PARAMETERS"
                }
            };
        }

        // Validate term_type
        if term_type != "tm1" && term_type != "tm2" && term_type != "tm3" {
            return <http:BadRequest>{
                body: {
                    message: "Invalid term_type. Must be tm1, tm2, or tm3",
                    'error: "INVALID_TERM_TYPE"
                }
            };
        }

        // Proceed with getting average marks by subject if authorization checks pass
        AverageMarksBySubjectResponse|ErrorResponse|error result = getAverageMarksBySubject(year, term_type);

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

    // Get teacher performance - Only accessible by manager
    resource function get teacherperformance(@http:Header string? authorization) 
            returns TeacherPerformanceResponse|ErrorResponse|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Proceed with getting teacher performance if authorization checks pass
        TeacherPerformanceResponse|ErrorResponse|error result = getTeacherPerformance();

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

    // Get student progress - Only accessible by manager
    resource function get studentprogress(string year, @http:Header string? authorization) 
            returns StudentProgressResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate required parameters
        if year.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Year parameter is required",
                    'error: "INVALID_PARAMETERS"
                }
            };
        }

        // Proceed with getting student progress if authorization checks pass
        StudentProgressResponse|ErrorResponse|error result = getStudentProgress(year);

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

    // Get low performing subjects - Only accessible by manager
    resource function get lowperformingsubjects(string year, decimal? threshold, @http:Header string? authorization) 
            returns LowPerformingSubjectsResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate required parameters
        if year.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Year parameter is required",
                    'error: "INVALID_PARAMETERS"
                }
            };
        }

        // Proceed with getting low performing subjects if authorization checks pass
        LowPerformingSubjectsResponse|ErrorResponse|error result = getLowPerformingSubjects(year, threshold);

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

    // Get top performing courses - Only accessible by manager
    resource function get topcourses(string year, string term_type, @http:Header string? authorization) 
            returns TopPerformingCoursesResponse|ErrorResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        
        // Check if authorization header is present
        if authorization is () {
            return <http:Unauthorized>{
                body: {
                    message: "Authorization header is required",
                    'error: "MISSING_AUTHORIZATION"
                }
            };
        }

        // Validate access token and check if user role is manager
        boolean|auth:ErrorResponse roleCheck = auth:hasRole(authorization, "manager");
        
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
                    message: "Access denied. Manager role required",
                    'error: "INSUFFICIENT_PRIVILEGES"
                }
            };
        }

        // Validate required parameters
        if year.trim() == "" || term_type.trim() == "" {
            return <http:BadRequest>{
                body: {
                    message: "Year and term_type parameters are required",
                    'error: "INVALID_PARAMETERS"
                }
            };
        }

        // Validate term_type
        if term_type != "tm1" && term_type != "tm2" && term_type != "tm3" {
            return <http:BadRequest>{
                body: {
                    message: "Invalid term_type. Must be tm1, tm2, or tm3",
                    'error: "INVALID_TERM_TYPE"
                }
            };
        }

        // Proceed with getting top performing courses if authorization checks pass
        TopPerformingCoursesResponse|ErrorResponse|error result = getTopPerformingCourses(year, term_type);

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

    // Get student marks report by student ID - No authentication required
    resource function get student/[int studentId]/marks() 
            returns StudentMarksReportResponse|ErrorResponse|http:BadRequest|http:InternalServerError {
        
        // Validate student ID
        if studentId <= 0 {
            return <http:BadRequest>{
                body: {
                    message: "Invalid student ID. Must be a positive integer",
                    'error: "INVALID_STUDENT_ID"
                }
            };
        }

        // Get student marks report
        StudentMarksReportResponse|ErrorResponse|error result = getStudentMarksReport(studentId);

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

// Function to create and return the report service
public isolated function getReportService() returns ReportRestService {
    return new ReportRestService();
}
