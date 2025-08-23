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

// JWT Payload type
public type JwtPayload record {
    int user_id;
    string email;
    UserRole role;
    int exp;
    int iat;
    string jti;
};

// Authentication response types
public type LoginResponse record {
    string access_token;
    string refresh_token;
    User user;
    string message;
};

public type RefreshResponse record {
    string access_token;
    string message;
};

public type ErrorResponse record {
    string message;
    string 'error;
};

// Request/Response types for API
public type LoginRequest record {
    string email;
    string password;
};

public type RegisterRequest record {
    string email;
    string password;
    string name;
    string? phone_number?;
    string? dob?;
};

public type RefreshTokenRequest record {
    string refresh_token;
};

public type UserWithProfile record {
    User user;
    Profile? profile;
};

public type SuccessResponse record {
    string message;
    anydata data?;
};
