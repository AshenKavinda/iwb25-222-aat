import ballerina/log;

// Function to add test with user and type validation
public isolated function addTest(AddTestRequest addTestReq) returns AddTestResponse|ErrorResponse|error {
    // First validate the test type
    if !testDbConnection.validateTestType(addTestReq.t_type) {
        return {
            message: "Invalid test type. Must be one of: tm1, tm2, tm3",
            'error: "INVALID_TEST_TYPE"
        };
    }

    // Validate that the user exists and is an officer
    boolean|error userValidation = testDbConnection.validateUserIsOfficer(addTestReq.user_id);
    
    if userValidation is error {
        log:printError("Failed to validate user", 'error = userValidation);
        return {
            message: userValidation.message(),
            'error: "USER_VALIDATION_ERROR"
        };
    }
    
    if userValidation is boolean && !userValidation {
        return {
            message: "User ID does not exist or user is not an officer",
            'error: "INVALID_USER_OR_ROLE"
        };
    }

    // Validate that the subject exists
    boolean|error subjectValidation = testDbConnection.validateSubjectExists(addTestReq.subject_id);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject ID does not exist or subject is deleted",
            'error: "INVALID_SUBJECT"
        };
    }

    Test|error result = testDbConnection.addTest(
        addTestReq.t_name, addTestReq.t_type, addTestReq.year, addTestReq.user_id, addTestReq.subject_id
    );

    if result is error {
        log:printError("Failed to add test", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_TEST_ERROR"
        };
    }

    return {
        message: "Test added successfully",
        data: result
    };
}

// Function to update test
public isolated function updateTest(int testId, UpdateTestRequest updateTestReq) returns UpdateTestResponse|ErrorResponse|error {
    // Validate test type if provided
    if updateTestReq?.t_type is string {
        if !testDbConnection.validateTestType(updateTestReq?.t_type ?: "") {
            return {
                message: "Invalid test type. Must be one of: tm1, tm2, tm3",
                'error: "INVALID_TEST_TYPE"
            };
        }
    }

    // Validate subject if provided
    if updateTestReq?.subject_id is int {
        boolean|error subjectValidation = testDbConnection.validateSubjectExists(updateTestReq?.subject_id ?: 0);
        
        if subjectValidation is error {
            log:printError("Failed to validate subject", 'error = subjectValidation);
            return {
                message: subjectValidation.message(),
                'error: "SUBJECT_VALIDATION_ERROR"
            };
        }
        
        if subjectValidation is boolean && !subjectValidation {
            return {
                message: "Subject ID does not exist or subject is deleted",
                'error: "INVALID_SUBJECT"
            };
        }
    }

    // First validate that the test exists and belongs to a valid officer
    boolean|error testValidation = testDbConnection.validateTestBelongsToOfficer(testId);
    
    if testValidation is error {
        log:printError("Failed to validate test", 'error = testValidation);
        return {
            message: testValidation.message(),
            'error: "TEST_VALIDATION_ERROR"
        };
    }
    
    if testValidation is boolean && !testValidation {
        return {
            message: "Test not found or does not belong to a valid officer",
            'error: "INVALID_TEST_OR_USER"
        };
    }

    Test|error result = testDbConnection.updateTest(
        testId, updateTestReq?.t_name, updateTestReq?.t_type, updateTestReq?.year, updateTestReq?.subject_id
    );

    if result is error {
        log:printError("Failed to update test", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_TEST_ERROR"
        };
    }

    return {
        message: "Test updated successfully",
        data: result
    };
}

// Function to soft delete test
public isolated function softDeleteTest(int testId) returns DeleteTestResponse|ErrorResponse|error {
    // First validate that the test exists and belongs to a valid officer
    boolean|error testValidation = testDbConnection.validateTestBelongsToOfficer(testId);
    
    if testValidation is error {
        log:printError("Failed to validate test", 'error = testValidation);
        return {
            message: testValidation.message(),
            'error: "TEST_VALIDATION_ERROR"
        };
    }
    
    if testValidation is boolean && !testValidation {
        return {
            message: "Test not found or does not belong to a valid officer",
            'error: "INVALID_TEST_OR_USER"
        };
    }

    int|error result = testDbConnection.softDeleteTest(testId);

    if result is error {
        log:printError("Failed to delete test", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Test deleted successfully",
        test_id: result
    };
}

// Function to restore test
public isolated function restoreTest(int testId) returns RestoreTestResponse|ErrorResponse|error {
    // First validate that the deleted test exists and belongs to a valid officer
    boolean|error testValidation = testDbConnection.validateDeletedTestBelongsToOfficer(testId);
    
    if testValidation is error {
        log:printError("Failed to validate deleted test", 'error = testValidation);
        return {
            message: testValidation.message(),
            'error: "TEST_VALIDATION_ERROR"
        };
    }
    
    if testValidation is boolean && !testValidation {
        return {
            message: "Deleted test not found or does not belong to a valid officer",
            'error: "INVALID_TEST_OR_USER"
        };
    }

    Test|error result = testDbConnection.restoreTest(testId);

    if result is error {
        log:printError("Failed to restore test", 'error = result);
        return {
            message: result.message(),
            'error: "RESTORE_ERROR"
        };
    }

    return {
        message: "Test restored successfully",
        data: result
    };
}

// Function to get all tests
public isolated function getAllTests() returns GetAllTestsResponse|ErrorResponse|error {
    Test[]|error result = testDbConnection.getAllTests();

    if result is error {
        log:printError("Failed to retrieve tests", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Tests retrieved successfully",
        data: result
    };
}

// Function to get test by ID
public isolated function getTestById(int testId) returns GetTestByIdResponse|ErrorResponse|error {
    Test|error result = testDbConnection.getTestById(testId);

    if result is error {
        log:printError("Failed to retrieve test", 'error = result);
        return {
            message: result.message(),
            'error: "TEST_NOT_FOUND"
        };
    }

    return {
        message: "Test retrieved successfully",
        data: result
    };
}

// Function to get all deleted tests
public isolated function getDeletedTests() returns GetDeletedTestsResponse|ErrorResponse|error {
    Test[]|error result = testDbConnection.getDeletedTests();

    if result is error {
        log:printError("Failed to retrieve deleted tests", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Deleted tests retrieved successfully",
        data: result
    };
}

// Function to get all available years
public isolated function getAvailableYears() returns GetAvailableYearsResponse|ErrorResponse|error {
    string[]|error result = testDbConnection.getAvailableYears();

    if result is error {
        log:printError("Failed to retrieve available years", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Available years retrieved successfully",
        data: result
    };
}

// Function to get tests by type
public isolated function getTestsByType(string tType) returns GetTestsByTypeResponse|ErrorResponse|error {
    // Validate test type
    if !testDbConnection.validateTestType(tType) {
        return {
            message: "Invalid test type. Must be one of: tm1, tm2, tm3",
            'error: "INVALID_TEST_TYPE"
        };
    }

    Test[]|error result = testDbConnection.getTestsByType(tType);

    if result is error {
        log:printError("Failed to retrieve tests by type", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Tests retrieved successfully",
        data: result
    };
}

// Function to search tests by name
public isolated function searchTestsByName(string name) returns SearchTestsByNameResponse|ErrorResponse|error {
    // Add wildcard pattern for LIKE search
    string namePattern = "%" + name + "%";
    
    Test[]|error result = testDbConnection.searchTestsByName(namePattern);

    if result is error {
        log:printError("Failed to search tests by name", 'error = result);
        return {
            message: result.message(),
            'error: "SEARCH_ERROR"
        };
    }

    return {
        message: "Tests found successfully",
        data: result
    };
}

// Function to filter tests by year
public isolated function filterTestsByYear(string year) returns GetTestsByTypeResponse|ErrorResponse|error {
    Test[]|error result = testDbConnection.filterTestsByYear(year);

    if result is error {
        log:printError("Failed to filter tests by year", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Tests filtered successfully",
        data: result
    };
}

// Function to get tests by subject
public isolated function getTestsBySubject(int subjectId) returns GetTestsBySubjectResponse|ErrorResponse|error {
    // Validate that the subject exists
    boolean|error subjectValidation = testDbConnection.validateSubjectExists(subjectId);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject ID does not exist or subject is deleted",
            'error: "INVALID_SUBJECT"
        };
    }

    Test[]|error result = testDbConnection.getTestsBySubject(subjectId);

    if result is error {
        log:printError("Failed to retrieve tests by subject", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Tests retrieved successfully",
        data: result
    };
}
