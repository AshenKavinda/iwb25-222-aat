import ballerina/http;
import ballerina/log;
import school_performance_panel.authentication_service;
import school_performance_panel.user_service;
import school_performance_panel.student_service;
import school_performance_panel.subject_service;
import school_performance_panel.course_service;
import school_performance_panel.test_service;

// HTTP listener configuration
listener http:Listener httpListener = new (8080);

public function main() returns error? {
    log:printInfo("Starting School Performance Panel Authentication API...");
    
    // Attach services to the listener
    check httpListener.attach(authentication_service:getAuthService(), "/api/auth");
    check httpListener.attach(authentication_service:getHealthService(), "/api");
    check httpListener.attach(user_service:getUserService(), "/api/user");
    check httpListener.attach(student_service:getStudentService(), "/api/student");
    check httpListener.attach(subject_service:getSubjectService(), "/api/subject");
    check httpListener.attach(course_service:getCourseService(), "/api/course");
    check httpListener.attach(test_service:getTestService(), "/api/test");
    
    log:printInfo("School Performance Panel Authentication API started on port 8080");
    log:printInfo("API Endpoints:");
    log:printInfo("  POST /api/auth/login - Login for all users");
    log:printInfo("  POST /api/auth/register - Register guest users");
    log:printInfo("  POST /api/auth/refresh - Refresh access token");
    log:printInfo("  GET /api/auth/me - Get current user profile");
    log:printInfo("  POST /api/auth/validate - Validate access token");
    log:printInfo("  GET /api/health - Health check");
    log:printInfo("  POST /api/user - Add user with profile");
    log:printInfo("  PUT /api/user/{user_id} - Update user profile (no email/password)");
    log:printInfo("  DELETE /api/user/{user_id} - Soft delete user");
    log:printInfo("  POST /api/user/{user_id}/restore - Restore deleted user");
    log:printInfo("  POST /api/student - Add student (Officer only)");
    log:printInfo("  PUT /api/student/{student_id} - Update student (Officer only)");
    log:printInfo("  DELETE /api/student/{student_id} - Soft delete student (Officer only)");
    log:printInfo("  POST /api/student/{student_id}/restore - Restore student (Officer only)");
    log:printInfo("  GET /api/student - Get all students (Officer only)");
    log:printInfo("  GET /api/student/{student_id} - Get student by ID (Officer only)");
    log:printInfo("  GET /api/student/deleted - Get deleted students (Officer only)");
    log:printInfo("  GET /api/student/search?name={name} - Search students by name (Officer only)");
    log:printInfo("  POST /api/subject - Add subject (Officer only)");
    log:printInfo("  PUT /api/subject/{subject_id} - Update subject (Officer only)");
    log:printInfo("  DELETE /api/subject/{subject_id} - Soft delete subject (Officer only)");
    log:printInfo("  POST /api/subject/{subject_id}/restore - Restore subject (Officer only)");
    log:printInfo("  GET /api/subject - Get all subjects (Officer only)");
    log:printInfo("  GET /api/subject/{subject_id} - Get subject by ID (Officer only)");
    log:printInfo("  GET /api/subject/deleted - Get deleted subjects (Officer only)");
    log:printInfo("  GET /api/subject/search/{name} - Search subjects by name (Officer only)");
    log:printInfo("  POST /api/course - Add course (Officer only)");
    log:printInfo("  PUT /api/course/{course_id} - Update course (Officer only)");
    log:printInfo("  DELETE /api/course/{course_id} - Soft delete course (Officer only)");
    log:printInfo("  POST /api/course/{course_id}/restore - Restore course (Officer only)");
    log:printInfo("  GET /api/course - Get all courses (Officer only)");
    log:printInfo("  GET /api/course/{course_id} - Get course by ID (Officer only)");
    log:printInfo("  GET /api/course/deleted - Get deleted courses (Officer only)");
    log:printInfo("  GET /api/course/years - Get available years (Officer only)");
    log:printInfo("  GET /api/course/search/name/{name} - Search courses by name (Officer only)");
    log:printInfo("  GET /api/course/search/year/{year} - Search courses by year (Officer only)");
    log:printInfo("  GET /api/course/search/name/{name}/year/{year} - Search courses by name and year (Officer only)");
    log:printInfo("  POST /api/test - Add test (Officer only)");
    log:printInfo("  PUT /api/test/{test_id} - Update test (Officer only)");
    log:printInfo("  DELETE /api/test/{test_id} - Soft delete test (Officer only)");
    log:printInfo("  POST /api/test/{test_id}/restore - Restore test (Officer only)");
    log:printInfo("  GET /api/test - Get all tests (Officer only)");
    log:printInfo("  GET /api/test/{test_id} - Get test by ID (Officer only)");
    log:printInfo("  GET /api/test/deleted - Get deleted tests (Officer only)");
    log:printInfo("  GET /api/test/years - Get available years for tests (Officer only)");
    log:printInfo("  GET /api/test/types/{type} - Filter tests by type (tm1/tm2/tm3) (Officer only)");
    log:printInfo("  GET /api/test/year/{year} - Filter tests by year (Officer only)");
    log:printInfo("  GET /api/test/search/name/{name} - Search tests by name (Officer only)");
    log:printInfo("Authentication API is ready to accept requests");
}
