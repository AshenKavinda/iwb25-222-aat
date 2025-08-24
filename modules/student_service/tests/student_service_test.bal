import ballerina/io;
import ballerina/test;

// Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Student Service Test Suite Starting!");
}

// Test function for adding a student
@test:Config {}
function testAddStudent() {
    AddStudentRequest addReq = {
        parent_nic: "123456789V",
        full_name: "John Doe",
        dob: "2005-01-15",
        user_id: 1
    };
    
    AddStudentResponse|ErrorResponse|error result = addStudent(addReq);
    
    if result is AddStudentResponse {
        test:assertEquals(result.message, "Student added successfully");
        test:assertTrue(result.data.student_id is int);
    } else {
        test:assertFail("Expected successful student addition");
    }
}

// Test function for getting all students
@test:Config {}
function testGetAllStudents() {
    GetAllStudentsResponse|ErrorResponse|error result = getAllStudents();
    
    if result is GetAllStudentsResponse {
        test:assertEquals(result.message, "Students retrieved successfully");
        test:assertTrue(result.data is Student[]);
    } else {
        test:assertFail("Expected successful student retrieval");
    }
}

// Test function for searching students by name
@test:Config {}
function testSearchStudentsByName() {
    SearchStudentsByNameResponse|ErrorResponse|error result = searchStudentsByName("John");
    
    if result is SearchStudentsByNameResponse {
        test:assertEquals(result.message, "Students found successfully");
        test:assertTrue(result.data is Student[]);
    } else {
        test:assertFail("Expected successful student search");
    }
}

// After Suite Function
@test:AfterSuite
function afterSuiteFunc() {
    io:println("Student Service Test Suite Completed!");
}
