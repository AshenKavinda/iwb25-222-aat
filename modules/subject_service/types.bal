// Subject record type
public type Subject record {
    int subject_id?;
    string name;
    decimal weight;
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

// Add subject request type
public type AddSubjectRequest record {
    string name;
    decimal weight;
    int user_id;
};

// Add subject response type
public type AddSubjectResponse record {
    string message;
    Subject data;
};

// Update subject request type
public type UpdateSubjectRequest record {
    string? name?;
    decimal? weight?;
};

// Update subject response type
public type UpdateSubjectResponse record {
    string message;
    Subject data;
};

// Delete subject response type
public type DeleteSubjectResponse record {
    string message;
    int subject_id;
};

// Restore subject response type
public type RestoreSubjectResponse record {
    string message;
    Subject data;
};

// Get all subjects response type
public type GetAllSubjectsResponse record {
    string message;
    Subject[] data;
};

// Get subject by ID response type
public type GetSubjectByIdResponse record {
    string message;
    Subject data;
};

// Get deleted subjects response type
public type GetDeletedSubjectsResponse record {
    string message;
    Subject[] data;
};

// Search subjects by name response type
public type SearchSubjectsByNameResponse record {
    string message;
    Subject[] data;
};
