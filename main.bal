import ballerina/http;
import ballerina/log;
import school_performance_panel.authentication_service;
import school_performance_panel.user_service;
import school_performance_panel.student_service;

// HTTP listener configuration
listener http:Listener httpListener = new (8080);

public function main() returns error? {
    log:printInfo("Starting School Performance Panel Authentication API...");
    
    // Attach services to the listener
    check httpListener.attach(authentication_service:getAuthService(), "/api/auth");
    check httpListener.attach(authentication_service:getHealthService(), "/api");
    check httpListener.attach(user_service:getUserService(), "/api/user");
    check httpListener.attach(student_service:getStudentService(), "/api/student");
    
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
    log:printInfo("Authentication API is ready to accept requests");
}
