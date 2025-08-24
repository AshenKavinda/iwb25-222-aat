import ballerina/log;

// Function to add student with user validation
public isolated function addStudent(AddStudentRequest addStudentReq) returns AddStudentResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = studentDbConnection.validateUserIsOfficer(addStudentReq.user_id);
    
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

    Student|error result = studentDbConnection.addStudent(
        addStudentReq.parent_nic, addStudentReq.full_name, 
        addStudentReq.dob, addStudentReq.user_id
    );

    if result is error {
        log:printError("Failed to add student", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_STUDENT_ERROR"
        };
    }

    return {
        message: "Student added successfully",
        data: result
    };
}

// Function to update student
public isolated function updateStudent(int studentId, UpdateStudentRequest updateStudentReq) returns UpdateStudentResponse|ErrorResponse|error {
    // First validate that the student exists and belongs to a valid officer
    boolean|error studentValidation = studentDbConnection.validateStudentBelongsToOfficer(studentId);
    
    if studentValidation is error {
        log:printError("Failed to validate student", 'error = studentValidation);
        return {
            message: studentValidation.message(),
            'error: "STUDENT_VALIDATION_ERROR"
        };
    }
    
    if studentValidation is boolean && !studentValidation {
        return {
            message: "Student not found or does not belong to a valid officer",
            'error: "INVALID_STUDENT_OR_USER"
        };
    }

    Student|error result = studentDbConnection.updateStudent(
        studentId, updateStudentReq?.parent_nic, 
        updateStudentReq?.full_name, updateStudentReq?.dob
    );

    if result is error {
        log:printError("Failed to update student", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_STUDENT_ERROR"
        };
    }

    return {
        message: "Student updated successfully",
        data: result
    };
}

// Function to soft delete student
public isolated function softDeleteStudent(int studentId) returns DeleteStudentResponse|ErrorResponse|error {
    // First validate that the student exists and belongs to a valid officer
    boolean|error studentValidation = studentDbConnection.validateStudentBelongsToOfficer(studentId);
    
    if studentValidation is error {
        log:printError("Failed to validate student", 'error = studentValidation);
        return {
            message: studentValidation.message(),
            'error: "STUDENT_VALIDATION_ERROR"
        };
    }
    
    if studentValidation is boolean && !studentValidation {
        return {
            message: "Student not found or does not belong to a valid officer",
            'error: "INVALID_STUDENT_OR_USER"
        };
    }

    int|error result = studentDbConnection.softDeleteStudent(studentId);

    if result is error {
        log:printError("Failed to delete student", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Student deleted successfully",
        student_id: result
    };
}

// Function to restore student
public isolated function restoreStudent(int studentId) returns RestoreStudentResponse|ErrorResponse|error {
    // First validate that the deleted student exists and belongs to a valid officer
    boolean|error studentValidation = studentDbConnection.validateDeletedStudentBelongsToOfficer(studentId);
    
    if studentValidation is error {
        log:printError("Failed to validate deleted student", 'error = studentValidation);
        return {
            message: studentValidation.message(),
            'error: "STUDENT_VALIDATION_ERROR"
        };
    }
    
    if studentValidation is boolean && !studentValidation {
        return {
            message: "Deleted student not found or does not belong to a valid officer",
            'error: "INVALID_STUDENT_OR_USER"
        };
    }

    Student|error result = studentDbConnection.restoreStudent(studentId);

    if result is error {
        log:printError("Failed to restore student", 'error = result);
        return {
            message: result.message(),
            'error: "RESTORE_ERROR"
        };
    }

    return {
        message: "Student restored successfully",
        data: result
    };
}

// Function to get all students
public isolated function getAllStudents() returns GetAllStudentsResponse|ErrorResponse|error {
    Student[]|error result = studentDbConnection.getAllStudents();

    if result is error {
        log:printError("Failed to retrieve students", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Students retrieved successfully",
        data: result
    };
}

// Function to get student by ID
public isolated function getStudentById(int studentId) returns GetStudentByIdResponse|ErrorResponse|error {
    Student|error result = studentDbConnection.getStudentById(studentId);

    if result is error {
        log:printError("Failed to retrieve student", 'error = result);
        return {
            message: result.message(),
            'error: "STUDENT_NOT_FOUND"
        };
    }

    return {
        message: "Student retrieved successfully",
        data: result
    };
}

// Function to get all deleted students
public isolated function getDeletedStudents() returns GetDeletedStudentsResponse|ErrorResponse|error {
    Student[]|error result = studentDbConnection.getDeletedStudents();

    if result is error {
        log:printError("Failed to retrieve deleted students", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Deleted students retrieved successfully",
        data: result
    };
}

// Function to search students by full name
public isolated function searchStudentsByName(string name) returns SearchStudentsByNameResponse|ErrorResponse|error {
    // Add wildcard pattern for LIKE search
    string namePattern = "%" + name + "%";
    Student[]|error result = studentDbConnection.searchStudentsByName(namePattern);

    if result is error {
        log:printError("Failed to search students by name", 'error = result);
        return {
            message: result.message(),
            'error: "SEARCH_ERROR"
        };
    }

    return {
        message: "Students found successfully",
        data: result
    };
}
