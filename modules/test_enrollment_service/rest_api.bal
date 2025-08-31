import ballerina/http;
import ballerina/log;

// Test Enrollment REST API service
public service class TestEnrollmentRestService {
    *http:Service;
    
    // Add test enrollments
    resource function post .(AddTestEnrollmentRequest addTestEnrollmentReq) returns AddTestEnrollmentResponse|ErrorResponse|http:InternalServerError {
        AddTestEnrollmentResponse|ErrorResponse|error result = addTestEnrollments(addTestEnrollmentReq);
        
        if result is error {
            log:printError("Internal server error while adding test enrollments", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Delete test enrollments
    resource function delete .(DeleteTestEnrollmentRequest deleteTestEnrollmentReq) returns DeleteTestEnrollmentResponse|ErrorResponse|http:InternalServerError {
        DeleteTestEnrollmentResponse|ErrorResponse|error result = deleteTestEnrollments(deleteTestEnrollmentReq);
        
        if result is error {
            log:printError("Internal server error while deleting test enrollments", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get test enrollments by course ID and test ID
    resource function get course/[int courseId]/test/[int testId]() returns GetTestEnrollmentsByCourseAndTestResponse|ErrorResponse|http:InternalServerError {
        GetTestEnrollmentsByCourseAndTestResponse|ErrorResponse|error result = getTestEnrollmentsByCourseAndTest(courseId, testId);
        
        if result is error {
            log:printError("Internal server error while getting test enrollments", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Update mark by record ID
    resource function put [int recordId]/mark(UpdateMarkRequest updateMarkReq) returns UpdateMarkResponse|ErrorResponse|http:InternalServerError {
        UpdateMarkResponse|ErrorResponse|error result = updateMarkByRecordId(recordId, updateMarkReq);
        
        if result is error {
            log:printError("Internal server error while updating mark", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
}

// Get test enrollment service instance
public isolated function getTestEnrollmentService() returns TestEnrollmentRestService {
    return new TestEnrollmentRestService();
}
