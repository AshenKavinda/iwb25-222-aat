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

// Update user request type (no password or email updates allowed)
public type UpdateUserRequest record {
    UserRole? role?;
    string? name?;
    string? phone_number?;
    string? dob?;
};

// Update user response type
public type UpdateUserResponse record {
    string message;
    UserWithProfile data;
};

// Delete user response type
public type DeleteUserResponse record {
    string message;
    int user_id;
};

// Restore user response type
public type RestoreUserResponse record {
    string message;
    UserWithProfile data;
};

// Get all users response type
public type GetAllUsersResponse record {
    string message;
    UserWithProfile[] data;
};

// Get user by ID response type
public type GetUserByIdResponse record {
    string message;
    UserWithProfile data;
};

// Get deleted users response type
public type GetDeletedUsersResponse record {
    string message;
    UserWithProfile[] data;
};

// Search users by email response type
public type SearchUsersByEmailResponse record {
    string message;
    UserWithProfile[] data;
};
