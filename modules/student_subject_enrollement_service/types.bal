// Student Subject Enrollment record type
public type StudentSubjectEnrollment record {|
    int record_id?;
    int student_id;
    int subject_id;
    int course_id;
    int user_id;
    string created_at?;
    string updated_at?;
|};

// Error response type
public type ErrorResponse record {|
    string message;
    string 'error;
|};

// Add common subjects to all students in course request type
public type AddCommonSubjectsRequest record {|
    int course_id;
    int[] subject_ids;
    int user_id;
|};

// Add common subjects to all students in course response type
public type AddCommonSubjectsResponse record {|
    string message;
    StudentSubjectEnrollment[] data;
|};

// Add subjects to specific student request type
public type AddSubjectsToStudentRequest record {|
    int student_id;
    int course_id;
    int[] subject_ids;
    int user_id;
|};

// Add subjects to specific student response type
public type AddSubjectsToStudentResponse record {|
    string message;
    StudentSubjectEnrollment[] data;
|};

// Update student subject enrollment request type
public type UpdateStudentSubjectEnrollmentRequest record {|
    int? student_id?;
    int? subject_id?;
    int? course_id?;
|};

// Update student subject enrollment response type
public type UpdateStudentSubjectEnrollmentResponse record {|
    string message;
    StudentSubjectEnrollment data;
|};

// Delete student subject enrollment response type
public type DeleteStudentSubjectEnrollmentResponse record {|
    string message;
    int record_id;
|};

// Get student subject enrollment by ID response type
public type GetStudentSubjectEnrollmentByIdResponse record {|
    string message;
    StudentSubjectEnrollment data;
|};

// Extended Student Subject Enrollment record with details
public type StudentSubjectEnrollmentWithDetails record {|
    int record_id;
    int student_id;
    string student_name;
    int subject_id;
    string subject_name;
    decimal? subject_weight;
    int course_id;
    string course_name;
    string course_year;
    int user_id;
    string created_at;
    string updated_at;
|};

// Get student subject enrollments with details response type
public type GetStudentSubjectEnrollmentsWithDetailsResponse record {|
    string message;
    StudentSubjectEnrollmentWithDetails[] data;
|};
