import ballerina/log;

// Function to add subject with user validation
public isolated function addSubject(AddSubjectRequest addSubjectReq) returns AddSubjectResponse|ErrorResponse|error {
    // Validate weight range (1-10) at service level
    decimal minWeight = 1.0;
    decimal maxWeight = 10.0;
    if addSubjectReq.weight < minWeight || addSubjectReq.weight > maxWeight {
        return {
            message: "Weight must be between 1 and 10",
            'error: "INVALID_WEIGHT"
        };
    }
    
    // First validate that the user exists and is an officer
    boolean|error userValidation = subjectDbConnection.validateUserIsOfficer(addSubjectReq.user_id);
    
    if userValidation is error {
        log:printError("Failed to validate user", 'error = userValidation);
        return {
            message: userValidation.message(),
            'error: "USER_VALIDATION_ERROR"
        };
    }
    
    if userValidation is boolean && !userValidation {
        return {
            message: "User ID does not exist or user is not an officer",
            'error: "INVALID_USER_OR_ROLE"
        };
    }

    Subject|error result = subjectDbConnection.addSubject(
        addSubjectReq.name, addSubjectReq.weight, addSubjectReq.user_id
    );

    if result is error {
        log:printError("Failed to add subject", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_SUBJECT_ERROR"
        };
    }

    return {
        message: "Subject added successfully",
        data: result
    };
}

// Function to update subject
public isolated function updateSubject(int subjectId, UpdateSubjectRequest updateSubjectReq) returns UpdateSubjectResponse|ErrorResponse|error {
    // Validate weight range if provided
    if updateSubjectReq?.weight is decimal {
        decimal weight = <decimal>updateSubjectReq?.weight;
        decimal minWeight = 1.0;
        decimal maxWeight = 10.0;
        if weight < minWeight || weight > maxWeight {
            return {
                message: "Weight must be between 1 and 10",
                'error: "INVALID_WEIGHT"
            };
        }
    }
    
    // First validate that the subject exists and belongs to a valid officer
    boolean|error subjectValidation = subjectDbConnection.validateSubjectBelongsToOfficer(subjectId);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject not found or does not belong to a valid officer",
            'error: "INVALID_SUBJECT_OR_USER"
        };
    }

    Subject|error result = subjectDbConnection.updateSubject(
        subjectId, updateSubjectReq?.name, updateSubjectReq?.weight
    );

    if result is error {
        log:printError("Failed to update subject", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_SUBJECT_ERROR"
        };
    }

    return {
        message: "Subject updated successfully",
        data: result
    };
}

// Function to soft delete subject
public isolated function softDeleteSubject(int subjectId) returns DeleteSubjectResponse|ErrorResponse|error {
    // First validate that the subject exists and belongs to a valid officer
    boolean|error subjectValidation = subjectDbConnection.validateSubjectBelongsToOfficer(subjectId);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject not found or does not belong to a valid officer",
            'error: "INVALID_SUBJECT_OR_USER"
        };
    }

    int|error result = subjectDbConnection.softDeleteSubject(subjectId);

    if result is error {
        log:printError("Failed to delete subject", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Subject deleted successfully",
        subject_id: result
    };
}

// Function to restore subject
public isolated function restoreSubject(int subjectId) returns RestoreSubjectResponse|ErrorResponse|error {
    // First validate that the deleted subject exists and belongs to a valid officer
    boolean|error subjectValidation = subjectDbConnection.validateDeletedSubjectBelongsToOfficer(subjectId);
    
    if subjectValidation is error {
        log:printError("Failed to validate deleted subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Deleted subject not found or does not belong to a valid officer",
            'error: "INVALID_SUBJECT_OR_USER"
        };
    }

    Subject|error result = subjectDbConnection.restoreSubject(subjectId);

    if result is error {
        log:printError("Failed to restore subject", 'error = result);
        return {
            message: result.message(),
            'error: "RESTORE_ERROR"
        };
    }

    return {
        message: "Subject restored successfully",
        data: result
    };
}

// Function to get all subjects
public isolated function getAllSubjects() returns GetAllSubjectsResponse|ErrorResponse|error {
    Subject[]|error result = subjectDbConnection.getAllSubjects();

    if result is error {
        log:printError("Failed to retrieve subjects", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Subjects retrieved successfully",
        data: result
    };
}

// Function to get subject by ID
public isolated function getSubjectById(int subjectId) returns GetSubjectByIdResponse|ErrorResponse|error {
    Subject|error result = subjectDbConnection.getSubjectById(subjectId);

    if result is error {
        log:printError("Failed to retrieve subject", 'error = result);
        return {
            message: result.message(),
            'error: "SUBJECT_NOT_FOUND"
        };
    }

    return {
        message: "Subject retrieved successfully",
        data: result
    };
}

// Function to get all deleted subjects
public isolated function getDeletedSubjects() returns GetDeletedSubjectsResponse|ErrorResponse|error {
    Subject[]|error result = subjectDbConnection.getDeletedSubjects();

    if result is error {
        log:printError("Failed to retrieve deleted subjects", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Deleted subjects retrieved successfully",
        data: result
    };
}

// Function to search subjects by name
public isolated function searchSubjectsByName(string name) returns SearchSubjectsByNameResponse|ErrorResponse|error {
    // Add wildcard pattern for LIKE search
    string namePattern = "%" + name + "%";
    Subject[]|error result = subjectDbConnection.searchSubjectsByName(namePattern);

    if result is error {
        log:printError("Failed to search subjects by name", 'error = result);
        return {
            message: result.message(),
            'error: "SEARCH_ERROR"
        };
    }

    return {
        message: "Subjects found successfully",
        data: result
    };
}
