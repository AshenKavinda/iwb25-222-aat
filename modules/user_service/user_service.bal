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
