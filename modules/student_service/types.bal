// Student record type
public type Student record {
    int student_id?;
    string parent_nic;
    string full_name;
    string dob;
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

// Add student request type
public type AddStudentRequest record {
    string parent_nic;
    string full_name;
    string dob;
    int user_id;
};

// Add student response type
public type AddStudentResponse record {
    string message;
    Student data;
};

// Update student request type
public type UpdateStudentRequest record {
    string? parent_nic?;
    string? full_name?;
    string? dob?;
};

// Update student response type
public type UpdateStudentResponse record {
    string message;
    Student data;
};

// Delete student response type
public type DeleteStudentResponse record {
    string message;
    int student_id;
};

// Restore student response type
public type RestoreStudentResponse record {
    string message;
    Student data;
};

// Get all students response type
public type GetAllStudentsResponse record {
    string message;
    Student[] data;
};

// Get student by ID response type
public type GetStudentByIdResponse record {
    string message;
    Student data;
};

// Get deleted students response type
public type GetDeletedStudentsResponse record {
    string message;
    Student[] data;
};

// Search students by full name response type
public type SearchStudentsByNameResponse record {
    string message;
    Student[] data;
};
