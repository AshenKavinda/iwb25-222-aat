import ballerina/http;
// User REST API service
public service class UserRestService {
    *http:Service;

    // POST / - Add user with profile
    resource function post .(@http:Payload AddUserRequest addUserReq) 
            returns AddUserResponse|ErrorResponse|http:BadRequest|http:InternalServerError {
        
        AddUserResponse|ErrorResponse|error result = addUserWithProfile(addUserReq);

        if result is ErrorResponse {
            return http:INTERNAL_SERVER_ERROR;
        }

        if result is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return result;
    }
}

// Function to create and return the user service
public isolated function getUserService() returns UserRestService {
    return new UserRestService();
}
