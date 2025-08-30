// Course Subject Enrollment record type for subject_course_teacher table
public type CourseSubjectEnrollment record {
    int record_id?;
    int subject_id;
    int course_id;
    int teacher_id;
    int user_id;
    string created_at?;
    string updated_at?;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add course subject enrollment request type
public type AddCourseSubjectEnrollmentRequest record {
    int subject_id;
    int course_id;
    int teacher_id;
    int user_id;
};

// Add course subject enrollment response type
public type AddCourseSubjectEnrollmentResponse record {
    string message;
    CourseSubjectEnrollment data;
};

// Update course subject enrollment request type (only subject_id field)
public type UpdateCourseSubjectEnrollmentRequest record {
    int subject_id;
};

// Update course subject enrollment response type
public type UpdateCourseSubjectEnrollmentResponse record {
    string message;
    CourseSubjectEnrollment data;
};

// Delete course subject enrollment response type
public type DeleteCourseSubjectEnrollmentResponse record {
    string message;
    int record_id;
};

// Get course subject enrollments by course ID response type
public type GetCourseSubjectEnrollmentsByCourseIdResponse record {
    string message;
    CourseSubjectEnrollment[] data;
};

// Extended Course Subject Enrollment record with details
public type CourseSubjectEnrollmentWithDetails record {
    int record_id;
    int subject_id;
    string subject_name;
    decimal? subject_weight;
    int course_id;
    string course_name;
    string course_year;
    string course_hall?;
    int teacher_id;
    string teacher_name;
    int user_id;
    string created_at;
    string updated_at;
};

// Get course subject enrollments by teacher ID response type with details
public type GetCourseSubjectEnrollmentsByTeacherIdResponse record {
    string message;
    CourseSubjectEnrollmentWithDetails[] data;
};
