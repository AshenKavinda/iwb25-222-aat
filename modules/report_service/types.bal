// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Top performing students report record
public type TopPerformingStudent record {
    int student_id;
    string full_name;
    string course_name;
    string year;
    string t_type;
    decimal total_marks;
};

// Average marks per subject report record
public type AverageMarksBySubject record {
    string subject_name;
    string course_name;
    string t_type;
    string year;
    decimal avg_mark;
};

// Teacher performance report record
public type TeacherPerformance record {
    int teacher_id;
    string teacher_name;
    string subject_name;
    decimal avg_student_marks;
};

// Student progress across terms record
public type StudentProgress record {
    string full_name;
    string subject_name;
    string year;
    decimal tm1_marks;
    decimal tm2_marks;
    decimal tm3_marks;
};

// Low performing subjects record
public type LowPerformingSubject record {
    string subject_name;
    string course_name;
    decimal avg_marks;
};

// Top performing courses record
public type TopPerformingCourse record {
    string course_name;
    string year;
    string t_type;
    decimal avg_marks;
};

// Top performing students response
public type TopPerformingStudentsResponse record {
    string message;
    TopPerformingStudent[] data;
};

// Average marks per subject response
public type AverageMarksBySubjectResponse record {
    string message;
    AverageMarksBySubject[] data;
};

// Teacher performance response
public type TeacherPerformanceResponse record {
    string message;
    TeacherPerformance[] data;
};

// Student progress response
public type StudentProgressResponse record {
    string message;
    StudentProgress[] data;
};

// Low performing subjects response
public type LowPerformingSubjectsResponse record {
    string message;
    LowPerformingSubject[] data;
};

// Top performing courses response
public type TopPerformingCoursesResponse record {
    string message;
    TopPerformingCourse[] data;
};

// Report filter request types
public type ReportFilterRequest record {
    string year?;
    string term_type?;
    int limitCount?;
    decimal? threshold?;
};
