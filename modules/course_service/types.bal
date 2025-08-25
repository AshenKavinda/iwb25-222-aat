// Course record type
public type Course record {
    int course_id?;
    string name;
    string? hall?;
    string year;
    int user_id;
    string created_at?;
    string updated_at?;
    string? deleted_at?;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add course request type
public type AddCourseRequest record {
    string name;
    string? hall?;
    string year;
    int user_id;
};

// Add course response type
public type AddCourseResponse record {
    string message;
    Course data;
};

// Update course request type
public type UpdateCourseRequest record {
    string? name?;
    string? hall?;
    string? year?;
};

// Update course response type
public type UpdateCourseResponse record {
    string message;
    Course data;
};

// Delete course response type
public type DeleteCourseResponse record {
    string message;
    int course_id;
};

// Restore course response type
public type RestoreCourseResponse record {
    string message;
    Course data;
};

// Get all courses response type
public type GetAllCoursesResponse record {
    string message;
    Course[] data;
};

// Get course by ID response type
public type GetCourseByIdResponse record {
    string message;
    Course data;
};

// Get deleted courses response type
public type GetDeletedCoursesResponse record {
    string message;
    Course[] data;
};

// Get available years response type
public type GetAvailableYearsResponse record {
    string message;
    string[] data;
};

// Search courses by name and year response type
public type SearchCoursesByNameAndYearResponse record {
    string message;
    Course[] data;
};
