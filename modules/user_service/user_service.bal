import ballerina/log;

// Function to add user with profile
public isolated function addUserWithProfile(AddUserRequest addUserReq) returns AddUserResponse|ErrorResponse|error {
    UserWithProfile|error result = dbConnection.addUserWithProfile(
        addUserReq.email, addUserReq.password, addUserReq.role, 
        addUserReq.name, addUserReq?.phone_number, addUserReq?.dob
    );

    if result is error {
        log:printError("Failed to add user", 'error = result);
        return error("Internal Server Error");
    }

    return {
        message: "User added successfully",
        data: result
    };
}

// Function to update user with profile (no password or email updates allowed)
public isolated function updateUserWithProfile(int userId, UpdateUserRequest updateUserReq) returns UpdateUserResponse|ErrorResponse|error {
    UserWithProfile|error result = dbConnection.updateUserWithProfile(
        userId, updateUserReq?.role, updateUserReq?.name, 
        updateUserReq?.phone_number, updateUserReq?.dob
    );

    if result is error {
        log:printError("Failed to update user", 'error = result);
        return error("Internal Server Error");
    }

    return {
        message: "User updated successfully",
        data: result
    };
}

// Function to soft delete user
public isolated function softDeleteUser(int userId) returns DeleteUserResponse|ErrorResponse|error {
    int|error result = dbConnection.softDeleteUser(userId);

    if result is error {
        log:printError("Failed to delete user", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "User deleted successfully",
        user_id: result
    };
}

// Function to restore user
public isolated function restoreUser(int userId) returns RestoreUserResponse|ErrorResponse|error {
    UserWithProfile|error result = dbConnection.restoreUser(userId);

    if result is error {
        log:printError("Failed to restore user", 'error = result);
        return {
            message: result.message(),
            'error: "RESTORE_ERROR"
        };
    }

    return {
        message: "User restored successfully",
        data: result
    };
}

// Function to get all users
public isolated function getAllUsersWithProfiles() returns GetAllUsersResponse|ErrorResponse|error {
    UserWithProfile[]|error result = dbConnection.getAllUsers();

    if result is error {
        log:printError("Failed to retrieve users", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Users retrieved successfully",
        data: result
    };
}

// Function to get user by ID
public isolated function getUserByIdWithProfile(int userId) returns GetUserByIdResponse|ErrorResponse|error {
    UserWithProfile|error result = dbConnection.getUserById(userId);

    if result is error {
        log:printError("Failed to retrieve user", 'error = result);
        return {
            message: result.message(),
            'error: "USER_NOT_FOUND"
        };
    }

    return {
        message: "User retrieved successfully",
        data: result
    };
}

// Function to get all deleted users
public isolated function getDeletedUsersWithProfiles() returns GetDeletedUsersResponse|ErrorResponse|error {
    UserWithProfile[]|error result = dbConnection.getDeletedUsers();

    if result is error {
        log:printError("Failed to retrieve deleted users", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Deleted users retrieved successfully",
        data: result
    };
}

// Function to search users by email
public isolated function searchUsersByEmailWithProfiles(string email) returns SearchUsersByEmailResponse|ErrorResponse|error {
    // Add wildcard pattern for LIKE search
    string emailPattern = "%" + email + "%";
    UserWithProfile[]|error result = dbConnection.searchUsersByEmail(emailPattern);

    if result is error {
        log:printError("Failed to search users by email", 'error = result);
        return {
            message: result.message(),
            'error: "SEARCH_ERROR"
        };
    }

    return {
        message: "Users found successfully",
        data: result
    };
}
