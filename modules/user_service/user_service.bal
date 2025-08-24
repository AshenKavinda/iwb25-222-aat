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
