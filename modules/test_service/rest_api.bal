import ballerina/http;
import ballerina/log;

// Test REST API service
public service class TestRestService {
    *http:Service;
    
    // Add new test
    resource function post .(AddTestRequest addTestReq) returns AddTestResponse|ErrorResponse|http:InternalServerError {
        AddTestResponse|ErrorResponse|error result = addTest(addTestReq);
        
        if result is error {
            log:printError("Internal server error while adding test", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all tests
    resource function get .() returns GetAllTestsResponse|ErrorResponse|http:InternalServerError {
        GetAllTestsResponse|ErrorResponse|error result = getAllTests();
        
        if result is error {
            log:printError("Internal server error while retrieving tests", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get test by ID
    resource function get [int testId]() returns GetTestByIdResponse|ErrorResponse|http:InternalServerError {
        GetTestByIdResponse|ErrorResponse|error result = getTestById(testId);
        
        if result is error {
            log:printError("Internal server error while retrieving test", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Update test
    resource function put [int testId](UpdateTestRequest updateTestReq) returns UpdateTestResponse|ErrorResponse|http:InternalServerError {
        UpdateTestResponse|ErrorResponse|error result = updateTest(testId, updateTestReq);
        
        if result is error {
            log:printError("Internal server error while updating test", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Soft delete test
    resource function delete [int testId]() returns DeleteTestResponse|ErrorResponse|http:InternalServerError {
        DeleteTestResponse|ErrorResponse|error result = softDeleteTest(testId);
        
        if result is error {
            log:printError("Internal server error while deleting test", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Restore test
    resource function post [int testId]/restore() returns RestoreTestResponse|ErrorResponse|http:InternalServerError {
        RestoreTestResponse|ErrorResponse|error result = restoreTest(testId);
        
        if result is error {
            log:printError("Internal server error while restoring test", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all deleted tests
    resource function get deleted() returns GetDeletedTestsResponse|ErrorResponse|http:InternalServerError {
        GetDeletedTestsResponse|ErrorResponse|error result = getDeletedTests();
        
        if result is error {
            log:printError("Internal server error while retrieving deleted tests", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all available years
    resource function get years() returns GetAvailableYearsResponse|ErrorResponse|http:InternalServerError {
        GetAvailableYearsResponse|ErrorResponse|error result = getAvailableYears();
        
        if result is error {
            log:printError("Internal server error while retrieving available years", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get tests by type
    resource function get types/[string tType]() returns GetTestsByTypeResponse|ErrorResponse|http:InternalServerError {
        GetTestsByTypeResponse|ErrorResponse|error result = getTestsByType(tType);
        
        if result is error {
            log:printError("Internal server error while retrieving tests by type", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Filter tests by year
    resource function get year/[string year]() returns GetTestsByTypeResponse|ErrorResponse|http:InternalServerError {
        GetTestsByTypeResponse|ErrorResponse|error result = filterTestsByYear(year);
        
        if result is error {
            log:printError("Internal server error while filtering tests by year", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Search tests by name
    resource function get search/name/[string name]() returns SearchTestsByNameResponse|ErrorResponse|http:InternalServerError {
        SearchTestsByNameResponse|ErrorResponse|error result = searchTestsByName(name);
        
        if result is error {
            log:printError("Internal server error while searching tests by name", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get tests by subject
    resource function get subject/[int subjectId]() returns GetTestsBySubjectResponse|ErrorResponse|http:InternalServerError {
        GetTestsBySubjectResponse|ErrorResponse|error result = getTestsBySubject(subjectId);
        
        if result is error {
            log:printError("Internal server error while retrieving tests by subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
}

// Get test service instance
public isolated function getTestService() returns TestRestService {
    return new TestRestService();
}
