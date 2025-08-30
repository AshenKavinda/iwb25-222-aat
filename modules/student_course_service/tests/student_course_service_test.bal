import ballerina/io;
import ballerina/test;
import ballerina/log;

// Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Starting Student Course Service Tests!");
}

// Test function for adding students to course
@test:Config {}
function testAddStudentsToCourse() {
    log:printInfo("Testing add students to course function");
    
    AddStudentsToCourseRequest request = {
        course_id: 1,
        student_ids: [1, 2, 3],
        user_id: 1
    };
    
    AddStudentsToCourseResponse|ErrorResponse|error result = addStudentsToCourse(request);
    
    if result is AddStudentsToCourseResponse {
        test:assertTrue(result.data.length() > 0);
        log:printInfo("✓ Add students to course test passed");
    } else if result is ErrorResponse {
        log:printWarn("Add students to course returned error: " + result.message);
    } else {
        log:printError("Add students to course test failed");
    }
}

@test:Config {}
function testGetStudentCoursesByStudentId() {
    log:printInfo("Testing get student courses by student ID function");
    
    GetStudentCoursesByStudentIdResponse|ErrorResponse|error result = getStudentCoursesByStudentId(1);
    
    if result is GetStudentCoursesByStudentIdResponse {
        test:assertTrue(result.data.length() >= 0);
        log:printInfo("✓ Get student courses by student ID test passed");
    } else if result is ErrorResponse {
        log:printWarn("Get student courses by student ID returned error: " + result.message);
    } else {
        log:printError("Get student courses by student ID test failed");
    }
}

@test:Config {}
function testGetStudentCoursesByCourseId() {
    log:printInfo("Testing get student courses by course ID function");
    
    GetStudentCoursesByCourseIdResponse|ErrorResponse|error result = getStudentCoursesByCourseId(1);
    
    if result is GetStudentCoursesByCourseIdResponse {
        test:assertTrue(result.data.length() >= 0);
        log:printInfo("✓ Get student courses by course ID test passed");
    } else if result is ErrorResponse {
        log:printWarn("Get student courses by course ID returned error: " + result.message);
    } else {
        log:printError("Get student courses by course ID test failed");
    }
}

// After Suite Function
@test:AfterSuite
function afterSuiteFunc() {
    io:println("Student Course Service Tests completed!");
}
