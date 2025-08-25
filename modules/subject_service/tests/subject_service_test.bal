import ballerina/test;
import ballerina/io;

// Test data
int testUserId = 1; // Assuming user with ID 1 is an officer
int testSubjectId = 0;
string testSubjectName = "Mathematics";
decimal testSubjectWeight = 5.5;

// Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("Starting Subject Service Tests");
}

// Test adding a subject with valid data
@test:Config {}
function testAddSubject() {
    AddSubjectRequest addReq = {
        name: testSubjectName,
        weight: testSubjectWeight,
        user_id: testUserId
    };
    
    AddSubjectResponse|ErrorResponse|error result = addSubject(addReq);
    
    if result is AddSubjectResponse {
        test:assertTrue(result.data.subject_id is int);
        test:assertEquals(result.data.name, testSubjectName);
        test:assertEquals(result.data.weight, testSubjectWeight);
        test:assertEquals(result.data.user_id, testUserId);
        testSubjectId = <int>result.data.subject_id;
        io:println("Subject added successfully with ID: " + testSubjectId.toString());
    } else {
        test:assertFail("Failed to add subject");
    }
}

// Test adding a subject with invalid weight (too low)
@test:Config {dependsOn: [testAddSubject]}
function testAddSubjectInvalidWeightLow() {
    AddSubjectRequest addReq = {
        name: "Physics",
        weight: 0.5, // Invalid weight - too low
        user_id: testUserId
    };
    
    AddSubjectResponse|ErrorResponse|error result = addSubject(addReq);
    
    if result is ErrorResponse {
        test:assertEquals(result.'error, "ADD_SUBJECT_ERROR");
    } else {
        test:assertFail("Should have failed with invalid weight");
    }
}

// Test adding a subject with invalid weight (too high)
@test:Config {dependsOn: [testAddSubject]}
function testAddSubjectInvalidWeightHigh() {
    AddSubjectRequest addReq = {
        name: "Chemistry",
        weight: 11.0, // Invalid weight - too high
        user_id: testUserId
    };
    
    AddSubjectResponse|ErrorResponse|error result = addSubject(addReq);
    
    if result is ErrorResponse {
        test:assertEquals(result.'error, "ADD_SUBJECT_ERROR");
    } else {
        test:assertFail("Should have failed with invalid weight");
    }
}

// Test getting all subjects
@test:Config {dependsOn: [testAddSubject]}
function testGetAllSubjects() {
    GetAllSubjectsResponse|ErrorResponse|error result = getAllSubjects();
    
    if result is GetAllSubjectsResponse {
        test:assertTrue(result.data.length() > 0);
        io:println("Retrieved " + result.data.length().toString() + " subjects");
    } else {
        test:assertFail("Failed to get all subjects");
    }
}

// Test getting subject by ID
@test:Config {dependsOn: [testAddSubject]}
function testGetSubjectById() {
    GetSubjectByIdResponse|ErrorResponse|error result = getSubjectById(testSubjectId);
    
    if result is GetSubjectByIdResponse {
        test:assertEquals(result.data.subject_id, testSubjectId);
        test:assertEquals(result.data.name, testSubjectName);
        test:assertEquals(result.data.weight, testSubjectWeight);
    } else {
        test:assertFail("Failed to get subject by ID");
    }
}

// Test updating subject
@test:Config {dependsOn: [testAddSubject]}
function testUpdateSubject() {
    UpdateSubjectRequest updateReq = {
        name: "Advanced Mathematics",
        weight: 7.5
    };
    
    UpdateSubjectResponse|ErrorResponse|error result = updateSubject(testSubjectId, updateReq);
    
    if result is UpdateSubjectResponse {
        test:assertEquals(result.data.name, "Advanced Mathematics");
        test:assertEquals(result.data.weight, 7.5);
        io:println("Subject updated successfully");
    } else {
        test:assertFail("Failed to update subject");
    }
}

// Test searching subjects by name
@test:Config {dependsOn: [testUpdateSubject]}
function testSearchSubjectsByName() {
    SearchSubjectsByNameResponse|ErrorResponse|error result = searchSubjectsByName("Math");
    
    if result is SearchSubjectsByNameResponse {
        test:assertTrue(result.data.length() > 0);
        io:println("Found " + result.data.length().toString() + " subjects matching 'Math'");
    } else {
        test:assertFail("Failed to search subjects by name");
    }
}

// Test soft deleting subject
@test:Config {dependsOn: [testUpdateSubject]}
function testSoftDeleteSubject() {
    DeleteSubjectResponse|ErrorResponse|error result = softDeleteSubject(testSubjectId);
    
    if result is DeleteSubjectResponse {
        test:assertEquals(result.subject_id, testSubjectId);
        io:println("Subject soft deleted successfully");
    } else {
        test:assertFail("Failed to soft delete subject");
    }
}

// Test getting deleted subjects
@test:Config {dependsOn: [testSoftDeleteSubject]}
function testGetDeletedSubjects() {
    GetDeletedSubjectsResponse|ErrorResponse|error result = getDeletedSubjects();
    
    if result is GetDeletedSubjectsResponse {
        test:assertTrue(result.data.length() > 0);
        io:println("Retrieved " + result.data.length().toString() + " deleted subjects");
    } else {
        test:assertFail("Failed to get deleted subjects");
    }
}

// Test restoring subject
@test:Config {dependsOn: [testSoftDeleteSubject]}
function testRestoreSubject() {
    RestoreSubjectResponse|ErrorResponse|error result = restoreSubject(testSubjectId);
    
    if result is RestoreSubjectResponse {
        test:assertEquals(result.data.subject_id, testSubjectId);
        test:assertTrue(result.data?.deleted_at is ());
        io:println("Subject restored successfully");
    } else {
        test:assertFail("Failed to restore subject");
    }
}

// Test getting subject by ID after restoration
@test:Config {dependsOn: [testRestoreSubject]}
function testGetSubjectByIdAfterRestore() {
    GetSubjectByIdResponse|ErrorResponse|error result = getSubjectById(testSubjectId);
    
    if result is GetSubjectByIdResponse {
        test:assertEquals(result.data.subject_id, testSubjectId);
        test:assertTrue(result.data?.deleted_at is ());
        io:println("Subject is accessible after restoration");
    } else {
        test:assertFail("Failed to get subject by ID after restoration");
    }
}

// Cleanup - Delete the test subject
@test:Config {dependsOn: [testGetSubjectByIdAfterRestore]}
function testCleanupSubject() {
    DeleteSubjectResponse|ErrorResponse|error result = softDeleteSubject(testSubjectId);
    
    if result is DeleteSubjectResponse {
        io:println("Test subject cleaned up successfully");
    } else {
        io:println("Warning: Failed to cleanup test subject");
    }
}

// After Suite Function
@test:AfterSuite
function afterSuiteFunc() {
    io:println("Subject Service Tests completed");
}
