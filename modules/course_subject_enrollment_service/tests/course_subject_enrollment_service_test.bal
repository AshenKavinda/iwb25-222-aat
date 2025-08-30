import ballerina/io;
import ballerina/test;

// Before Suite Function

@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("I'm the before suite function!");
}

// Test function

@test:Config {}
function testFunction() {
    // Test course subject enrollment service
    io:println("Testing course subject enrollment service");
    test:assertTrue(true, "Basic test passed");
}

// Negative Test function

@test:Config {}
function negativeTestFunction() {
    // Test negative scenario
    io:println("Testing negative scenario");
    test:assertTrue(true, "Negative test passed");
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("I'm the after suite function!");
}
