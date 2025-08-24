// User roles enum
public enum UserRole {
    MANAGER = "manager",
    TEACHER = "teacher",
    OFFICER = "officer",
    GUEST = "guest"
}

// User record type
public type User record {
    int user_id?;
    string email;
    string password?;
    UserRole role;
    string created_at?;
    string updated_at?;
    string? deleted_at?;
};

// Profile record type
public type Profile record {
    int profile_id?;
    string name;
    string? phone_number?;
    string? dob?;
    int user_id;
    string created_at?;
    string updated_at?;
    string? deleted_at?;
};

// User with profile type
public type UserWithProfile record {
    User user;
    Profile? profile;
};

// Error response type
public type ErrorResponse record {
    string message;
    string 'error;
};

// Add user request type
public type AddUserRequest record {
    string email;
    string password;
    UserRole role;
    string name;
    string? phone_number?;
    string? dob?;
};

// Add user response type
public type AddUserResponse record {
    string message;
    UserWithProfile data;
};
