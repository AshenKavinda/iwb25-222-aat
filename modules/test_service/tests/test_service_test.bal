import ballerina/test;

// Test data
final AddTestRequest testAddRequest = {
    t_name: "Mathematics Term Test 1",
    t_type: "tm1",
    year: "2024",
    user_id: 1 // Assuming user_id 1 is an officer
};

final UpdateTestRequest testUpdateRequest = {
    t_name: "Updated Mathematics Term Test 1",
    t_type: "tm2",
    year: "2025"
};

@test:Config {}
function testAddTest() returns error? {
    AddTestResponse|ErrorResponse|error result = addTest(testAddRequest);
    
    if result is AddTestResponse {
        test:assertEquals(result.message, "Test added successfully");
        test:assertEquals(result.data.t_name, testAddRequest.t_name);
        test:assertEquals(result.data.t_type, testAddRequest.t_type);
        test:assertEquals(result.data.year, testAddRequest.year);
        test:assertEquals(result.data.user_id, testAddRequest.user_id);
    } else {
        test:assertFail("Expected AddTestResponse, but got an error");
    }
}

@test:Config {}
function testAddTestInvalidType() returns error? {
    AddTestRequest invalidRequest = {
        t_name: "Invalid Test",
        t_type: "invalid_type",
        year: "2024",
        user_id: 1
    };
    
    AddTestResponse|ErrorResponse|error result = addTest(invalidRequest);
    
    if result is ErrorResponse {
        test:assertEquals(result.'error, "INVALID_TEST_TYPE");
    } else {
        test:assertFail("Expected ErrorResponse for invalid test type");
    }
}

@test:Config {}
function testGetAllTests() returns error? {
    GetAllTestsResponse|ErrorResponse|error result = getAllTests();
    
    if result is GetAllTestsResponse {
        test:assertEquals(result.message, "Tests retrieved successfully");
        test:assertTrue(result.data is Test[]);
    } else {
        test:assertFail("Expected GetAllTestsResponse, but got an error");
    }
}

@test:Config {}
function testGetTestsByValidType() returns error? {
    GetTestsByTypeResponse|ErrorResponse|error result = getTestsByType("tm1");
    
    if result is GetTestsByTypeResponse {
        test:assertEquals(result.message, "Tests retrieved successfully");
        test:assertTrue(result.data is Test[]);
    } else {
        test:assertFail("Expected GetTestsByTypeResponse, but got an error");
    }
}

@test:Config {}
function testGetTestsByInvalidType() returns error? {
    GetTestsByTypeResponse|ErrorResponse|error result = getTestsByType("invalid_type");
    
    if result is ErrorResponse {
        test:assertEquals(result.'error, "INVALID_TEST_TYPE");
    } else {
        test:assertFail("Expected ErrorResponse for invalid test type");
    }
}

@test:Config {}
function testSearchTestsByName() returns error? {
    SearchTestsByNameResponse|ErrorResponse|error result = searchTestsByName("Math");
    
    if result is SearchTestsByNameResponse {
        test:assertEquals(result.message, "Tests found successfully");
        test:assertTrue(result.data is Test[]);
    } else {
        test:assertFail("Expected SearchTestsByNameResponse, but got an error");
    }
}

@test:Config {}
function testFilterTestsByYear() returns error? {
    GetTestsByTypeResponse|ErrorResponse|error result = filterTestsByYear("2024");
    
    if result is GetTestsByTypeResponse {
        test:assertEquals(result.message, "Tests filtered successfully");
        test:assertTrue(result.data is Test[]);
    } else {
        test:assertFail("Expected GetTestsByTypeResponse, but got an error");
    }
}

@test:Config {}
function testGetAvailableYears() returns error? {
    GetAvailableYearsResponse|ErrorResponse|error result = getAvailableYears();
    
    if result is GetAvailableYearsResponse {
        test:assertEquals(result.message, "Available years retrieved successfully");
        test:assertTrue(result.data is string[]);
    } else {
        test:assertFail("Expected GetAvailableYearsResponse, but got an error");
    }
}
