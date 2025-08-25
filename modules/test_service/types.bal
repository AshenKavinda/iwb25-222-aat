// Test record type
public type Test record {
    int test_id?;
    string t_name;
    string t_type; // ENUM: 'tm1','tm2','tm3'
    string year;
    int user_id;
    int subject_id;
    string created_at?;
    string updated_at?;
    string? deleted_at?;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add test request type
public type AddTestRequest record {
    string t_name;
    string t_type; // ENUM: 'tm1','tm2','tm3'
    string year;
    int user_id;
    int subject_id;
};

// Add test response type
public type AddTestResponse record {
    string message;
    Test data;
};

// Update test request type
public type UpdateTestRequest record {
    string? t_name?;
    string? t_type?; // ENUM: 'tm1','tm2','tm3'
    string? year?;
    int? subject_id?;
};

// Update test response type
public type UpdateTestResponse record {
    string message;
    Test data;
};

// Delete test response type
public type DeleteTestResponse record {
    string message;
    int test_id;
};

// Restore test response type
public type RestoreTestResponse record {
    string message;
    Test data;
};

// Get all tests response type
public type GetAllTestsResponse record {
    string message;
    Test[] data;
};

// Get test by ID response type
public type GetTestByIdResponse record {
    string message;
    Test data;
};

// Get deleted tests response type
public type GetDeletedTestsResponse record {
    string message;
    Test[] data;
};

// Get available years response type
public type GetAvailableYearsResponse record {
    string message;
    string[] data;
};

// Get tests by type response type
public type GetTestsByTypeResponse record {
    string message;
    Test[] data;
};

// Search tests by name response type
public type SearchTestsByNameResponse record {
    string message;
    Test[] data;
};

// Get tests by subject response type
public type GetTestsBySubjectResponse record {
    string message;
    Test[] data;
};
