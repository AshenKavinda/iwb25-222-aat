import ballerina/http;
import ballerina/log;
import school_performance_panel.authentication_service;

// HTTP listener configuration
listener http:Listener httpListener = new (8080);

public function main() returns error? {
    log:printInfo("Starting School Performance Panel Authentication API...");
    
    // Attach services to the listener
    check httpListener.attach(authentication_service:getAuthService(), "/api/auth");
    check httpListener.attach(authentication_service:getHealthService(), "/api");
    
    log:printInfo("School Performance Panel Authentication API started on port 8080");
    log:printInfo("API Endpoints:");
    log:printInfo("  POST /api/auth/login - Login for all users");
    log:printInfo("  POST /api/auth/register - Register guest users");
    log:printInfo("  POST /api/auth/refresh - Refresh access token");
    log:printInfo("  GET /api/auth/me - Get current user profile");
    log:printInfo("  POST /api/auth/validate - Validate access token");
    log:printInfo("  GET /api/health - Health check");
    log:printInfo("Authentication API is ready to accept requests");
}
