// Student Course record type
public type StudentCourse record {
    int record_id?;
    int student_id;
    int course_id;
    int user_id;
    string created_at?;
    string updated_at?;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add students to course request type (bulk insertion)
public type AddStudentsToCourseRequest record {
    int course_id;
    int[] student_ids;
    int user_id;
};

// Add students to course response type
public type AddStudentsToCourseResponse record {
    string message;
    StudentCourse[] data;
};

// Update student course request type
public type UpdateStudentCourseRequest record {
    int? student_id?;
    int? course_id?;
};

// Update student course response type
public type UpdateStudentCourseResponse record {
    string message;
    StudentCourse data;
};

// Delete student course response type
public type DeleteStudentCourseResponse record {
    string message;
    int record_id;
};

// Get student course by ID response type
public type GetStudentCourseByIdResponse record {
    string message;
    StudentCourse data;
};

// Get student courses by student ID response type
public type GetStudentCoursesByStudentIdResponse record {
    string message;
    StudentCourse[] data;
};

// Get student courses by course ID response type
public type GetStudentCoursesByCourseIdResponse record {
    string message;
    StudentCourse[] data;
};

// Extended Student Course record with details
public type StudentCourseWithDetails record {
    int record_id;
    int student_id;
    string student_name;
    int course_id;
    string course_name;
    string course_year;
    int user_id;
    string created_at;
    string updated_at;
};

// Get student courses with details response type
public type GetStudentCoursesWithDetailsResponse record {
    string message;
    StudentCourseWithDetails[] data;
};
