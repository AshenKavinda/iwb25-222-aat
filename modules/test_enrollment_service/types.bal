// Test enrollment record type
public type TestEnrollment record {
    int record_id?;
    int student_id;
    int course_id;
    int subject_id;
    int test_id;
    decimal? mark?;
    int user_id;
    string created_at?;
    string updated_at?;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add test enrollment request type
public type AddTestEnrollmentRequest record {
    int course_id;
    int[] test_ids;
    int user_id;
};

// Add test enrollment response type
public type AddTestEnrollmentResponse record {
    string message;
    TestEnrollmentDetails data;
};

// Delete test enrollment request type
public type DeleteTestEnrollmentRequest record {
    int course_id;
    int[] test_ids;
    int user_id;
};

// Delete test enrollment response type
public type DeleteTestEnrollmentResponse record {
    string message;
    int affected_records;
};

// Test enrollment details for response
public type TestEnrollmentDetails record {
    int course_id;
    string course_name;
    int[] test_ids;
    int[] subject_ids;
    string[] subject_names;
    int total_students_enrolled;
    int total_records_created;
};

// Student test enrollment info
public type StudentTestEnrollmentInfo record {
    int student_id;
    string student_name;
    int course_id;
    string course_name;
    int subject_id;
    string subject_name;
    int test_id;
    string test_name;
    string test_type;
    decimal? mark;
};

// Test info for validation
public type TestInfo record {
    int test_id;
    string t_name;
    string t_type;
    string year;
    int subject_id;
    string subject_name;
};

// Student info for enrollment
public type StudentInfo record {
    int student_id;
    string full_name;
};

// Get test enrollments by course and test request type
public type GetTestEnrollmentsByCourseAndTestResponse record {
    string message;
    TestEnrollmentWithDetails[] data;
};

// Test enrollment with detailed information
public type TestEnrollmentWithDetails record {
    int record_id;
    int student_id;
    string student_name;
    int course_id;
    string course_name;
    int subject_id;
    string subject_name;
    int test_id;
    string test_name;
    string test_type;
    decimal? mark;
    string created_at;
    string updated_at;
};

// Update mark request type
public type UpdateMarkRequest record {
    decimal mark;
    int user_id;
};

// Update mark response type
public type UpdateMarkResponse record {
    string message;
    TestEnrollmentWithDetails data;
};
